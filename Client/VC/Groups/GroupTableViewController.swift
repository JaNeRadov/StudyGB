//
//  GroupTableViewController.swift
//  Client
//
//  Created by Jane Z. on 30.01.2023.
//

import UIKit
import Kingfisher
import RealmSwift
import FirebaseDatabase

class GroupTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
         subscribeToNotificationRealm() // загрузка данных из реалма (кэш) для первоначального отображения
        
        //запуск обновления данных из сети, запись в Реалм и загрузка из реалма новых данных
//        GetGroupsList().loadData()
        GetGroupsListOperations().getData() // способ с примененением Operations
    }
    
    var realm: Realm = {
        let configrealm = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        let realm = try! Realm(configuration: configrealm)
        return realm
    }()
    
    lazy var grousFromRealm: Results<Group> = {
        return realm.objects(Group.self)
    }()
    
    var notificationToken: NotificationToken?
    
    var myGroups: [Group] = []
    
    //MARK: - TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myGroups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsCell", for: indexPath) as! GroupTableViewCell
        
        cell.nameGroupLable.text = myGroups[indexPath.row].groupName
        if let imgURL = URL(string: myGroups[indexPath.row].groupLogo) {
            let avatar = ImageResource(downloadURL: imgURL) //арботает через kingfisher
            cell.avatarGroupView.avatarImage.kf.indicatorType = .activity //арботает через kingfisher
            cell .avatarGroupView.avatarImage.kf.setImage(with: avatar)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //удаление группы из реалма + обновление таблицы из реалма
            do {
                try realm.write{
                    realm.delete(grousFromRealm.filter("groupName == %@", myGroups[indexPath.row].groupName))
                }
            } catch {
                print(error)
            }
        }
    }
    
    //кратковременное подсвечивание при нажатии на ячейку
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Functions
    
    private func subscribeToNotificationRealm() {
        notificationToken = grousFromRealm.observe { [weak self] (changes) in
            switch changes {
            case .initial:
                self?.loadGroupsFromRealm()
            case .update:
                self?.loadGroupsFromRealm()
            case let .error(error):
                print(error)
            }
        }
    }
    
    func loadGroupsFromRealm() {
        myGroups = Array(grousFromRealm)
        guard grousFromRealm.count != 0 else { return } //проверка что в реалме есть данные
        tableView.reloadData()
    }
    
    //MARK: - Segue
    // добавление новой группы из другого контроллера
    @IBAction func addNewGroup(segue:UIStoryboardSegue) {
        // проверка по идентификатору верный ли переход с ячейки
        if segue.identifier == "AddGroup"{
            // ссылка объект на контроллер с которого переход
            guard let newGroupFromController = segue.source as? NewGroupTableViewController else { return }
            // проверка индекса ячейки
            if let indexPath = newGroupFromController.tableView.indexPathForSelectedRow {
                //добавить новой группы в мои группы из общего списка групп
                let newGroup = newGroupFromController.GroupsList[indexPath.row]
                
//                // проверка что группа уже в списке (нужен Equatable)
                guard myGroups.description.contains(newGroup.groupName) == false else { return }
                
                // добавить новую группу (не нужно, так как все берется из Реалма)
                //myGroups.append(newGroup)
                
                //  добавление новой группы в реалм
                do {
                    try realm.write{
                        realm.add(newGroup)
                    }
                } catch {
                    print(error)
                }
                
                writeNewGroupToFirebase(newGroup) // работа с Firebase
                
            }
        }
    }

// MARK:  - Firebase

private func writeNewGroupToFirebase(_ newGroup: Group){
    // работаем с Firebase
    let database = Database.database()
    // путь к нужному пользователю в Firebase (тот кто залогинился уже есть базе, другие не интересны)
    let ref: DatabaseReference = database.reference(withPath: "All logged users").child(String(Session.instance.userId))
    
    // чтение из Firebase
    ref.observe(.value) { snapshot in
        
        let groupsIDs = snapshot.children.compactMap { $0 as? DataSnapshot }
            .compactMap { $0.key }
        
        // проверка есть ли ID группы в Firebase
        guard groupsIDs.contains(String(newGroup.id)) == false else { return }

        //ref.removeAllObservers() // отписываемся от уведомлений, чтобы не происходило изменений при изменении базы
        ref.child(String(newGroup.id)).setValue(newGroup.groupName) // записываем новую группу в Firebase
        
        print("Для пользователя с ID: \(String(Session.instance.userId)) в Firebase записана группа:\n\(newGroup.groupName)")
        
        let groups = snapshot.children.compactMap { $0 as? DataSnapshot }
        .compactMap { $0.value }
        
        print("\nРанее добавленные в Firebase группы пользователя с ID \(String(Session.instance.userId)):\n\(groups)")
        ref.removeAllObservers() // отписываемся от уведомлений, чтобы не происходило изменений при записи в базу
    }
}
}
