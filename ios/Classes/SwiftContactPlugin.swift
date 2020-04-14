import Flutter
import ContactsUI

// 跳转原生选择联系人页面
let METHOD_CALL_NATIVE = "selectContactNative"
// 获取联系人列表
let METHOD_CALL_LIST = "selectContactList"

public class SwiftContactPlugin: NSObject, FlutterPlugin {

  static let CHANNEL = "plugins.flutter.io/easy_contact_picker"

  private var imagePickerController: UIImagePickerController?
  private var viewController: UIViewController?
  private var result: FlutterResult?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: registrar.messenger())
    let instance = SwiftContactPlugin()
    self.viewController = UIApplication.shared.delegate?.window?.rootViewController
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if self.result {
        self.result(FlutterError(code: "multiple_request", message: "Cancelled by a second request", details: nil))
        self.result = nil
    }
    //METHOD_CALL_NATIVE 跳转本地选择通讯录
    if (METHOD_CALL_NATIVE == call?.method) {
        self.result = result
        openContactPickerVC()
    } else if (METHOD_CALL_LIST == call?.method) {
        self.result = result
        getContactArray()
    }
  }

  // 打开通讯录
  func openContactPickerVC() {
    let contactPicker = CNContactPickerViewController()
    contactPicker.delegate = self
    contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
    viewController.present(contactPicker, animated: true)
  }

  ///  进入系统通讯录页面
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
    let phoneNumberModel = contactProperty.value as? CNPhoneNumber

    viewController.dismiss(animated: true) {
        /// 联系人
        let name = "\(contactProperty.contact.familyName)\(contactProperty.contact.givenName)"
        /// 电话
        var phoneNumber = phoneNumberModel?.stringValue
        phoneNumber = phoneNumber?.replacingOccurrences(of: "-", with: "")

        var dict: [AnyHashable : Any] = [:]
        dict["contactName"] = name
        dict["phoneNumber"] = phoneNumber
        self.result(dict)
    }
  }

  /// 获取联系人数据
  func getContactArray() {
      var contacts = [AnyHashable](repeating: 0, count: 1)
      let store = CNContactStore()
      store.requestAccess(for: .contacts, completionHandler: { granted, error in
        if granted {
          // 获取联系人仓库
          let store = CNContactStore()
          // 创建联系人信息的请求对象
          let keys = [
              CNContactGivenNameKey,
              CNContactFamilyNameKey,
              CNContactPhoneNumbersKey,
              CNContactNamePrefixKey,
              CNContactPhoneticFamilyNameKey
          ]
          // 根据请求Key, 创建请求对象
          let request = CNContactFetchRequest(keysToFetch: keys)
          // 发送请求
          do {
              try store.enumerateContacts(with: request, usingBlock: { _,_ in })
          } catch let { contact, stop in
              let contactModel = ContactModel()
              // 获取名字
              let givenName = contact.givenName
              // 获取姓氏
              let familyName = contact.familyName

              contactModel.contactName = "\(familyName)\(givenName)"
              // 获取电话
              let phoneArray = contact.phoneNumbers
              for labelValue in phoneArray {
                  guard let labelValue = labelValue as? CNLabeledValue else {
                      continue
                  }
                  let number = labelValue.value as? CNPhoneNumber
                  contactModel.phoneNumber = number?.stringValue
              }
              contacts.append(contactModel)
          result(defaultHandleContactObject(contacts))
        } else {
          result(FlutterError(code: "", message: "授权失败", details: ""))
        }
    })
  }

  func defaultHandleContactObject(_ contactObjects: [ContactModel]?) -> [[AnyHashable : Any]]? {
    return handleContactObjects(contactObjects, groupingByKeyPath: "name", sortInGroupKeyPath: "name")
  }

  func handleContactObjects(_ contactObjects: [ContactModel]?, groupingByKeyPath keyPath: String?, sortInGroupKeyPath sortInGroupkeyPath: String?) -> [[AnyHashable : Any]]? {
    let localizedCollation = UILocalizedIndexedCollation.current()

    //初始化数组返回的数组
    var contacts = [AnyHashable](repeating: 0, count: 0) as? [[AnyHashable]]

    /// 注:
    /// 为什么不直接用27，而用count呢，这里取决于初始化方式
    /// 初始化方式为[[Class alloc] init],那么这个count = 0
    /// 初始化方式为[Class currentCollation],那么这个count = 27

    //根据UILocalizedIndexedCollation的27个Title放入27个存储数据的数组
    for i in 0..<localizedCollation.sectionTitles.count {
        contacts?.append([AnyHashable](repeating: 0, count: 0))
    }

    //开始遍历联系人对象，进行分组
    for contactObject in contactObjects {
        //获取名字在UILocalizedIndexedCollation标头的索引数
        let section = localizedCollation.section(for: contactObject, collationStringSelector: NSSelectorFromString(keyPath))
        //获取索引对应的字母
        contactObject.firstLetter = localizedCollation.sectionTitles[section]
        //根据索引在相应的数组上添加数据
        contacts[section].append(contactObject)
    }

    //对每个同组的联系人进行排序
    for (NSInteger i = 0; i < localizedCollation.sectionTitles.count; i++)
    {
        //获取需要排序的数组
        NSMutableArray * tempMutableArray = contacts[i];
        //这里因为需要通过nameObject的name进行排序，排序器排序(排序方法有好几种，楼主选择的排序器排序)
        NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortInGroupkeyPath ascending:true];
        [tempMutableArray sortUsingDescriptors:@[sortDescriptor]];
        contacts[i] = tempMutableArray;
    }

    //新建一个temp空的数组（目的是为了在调用enumerateObjectsUsingBlock函数的时候把空的数组添加到这个数组里，
    //在将数据源空数组移除，或者在函数调用的时候进行判断，空的移除）
    var temp: [AnyHashable] = []
    contacts.enumerateObjects({ obj, idx, stop in
        if obj.count == 0 {
            temp.append(obj)
        }
    })

    //移除空数组
    contacts = contacts.filter({ !temp.contains($0) })

    //最终返回的数据
    var lastArray = [AnyHashable](repeating: 0, count: 1)
    contacts.enumerateObjects({ obj, idx, stop in

        (obj as NSArray).enumerateObjects({ model, idx, stop in
            var dict: [AnyHashable : Any] = [:]
            dict["fullName"] = model.contactName
            dict["phoneNumber"] = model.phoneNumber
            dict["firstLetter"] = model.firstLetter
            lastArray.append(dict)
        })
    })
    //返回
    return lastArray
  }
}
