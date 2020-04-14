
import Flutter

class ContactModel: NSObject {

    /// 姓名
    var _contactName: String?
    /// 联系方式
    var _phoneNumber: String?
    /// 首字母
    var _firstLetter: String?

    init(contactName: String?, phoneNumber: String?, firstLetter: String?) {
        super.init()
            _contactName = contactName
            _phoneNumber = phoneNumber
            _firstLetter = firstLetter
    }

    func phoneNumber() -> String? {
        if _phoneNumber == nil {
            return ""
        }
        return _phoneNumber
    }

    func contactName() -> String? {
        if contactName == nil {
            return ""
        }
        _contactName.replacingOccurrences(of: "-", with: "")
        return contactName
    }

    func firstLetter() -> String? {
        if _firstLetter == nil {
            return ""
        }
        return _firstLetter
    }
}