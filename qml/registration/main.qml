import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../validator.js" as Validator
import "../templates"


TemplateWindow {
    id: window
    windowHeigth: 720
    windowWidht: 980

    TitleBar {
        id: titleBar
        title: "Desktop messenger. Registration."
    }

    Container {
        id: container

        Rectangle {
            id: registrationBlock

            property bool isOff: false
            

            width: 400
            color: "transparent"

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }

            Label {
                id: header
                text: qsTr("Регистрация")
                font.pointSize: 20
                color: "white"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: 15
                }
            }

            // First name field
            ErrorLabel {
                id: firstNameLabel
                field: firstNameField
            }
            FirstNameField {
                id: firstNameField;
            }
            // Last name field
            ErrorLabel {
                id: lastNameFieldLabel
                field: lastNameField
            }
            LastNameField {
                id: lastNameField;
            }
            // Login field
            ErrorLabel {
                id: loginFieldLabel
                field: loginField
            }
            TipLabel {
                id: loginFieldTipLabel
                field: loginField
            }
            LoginField {
                id: loginField;
            }
            // Email field
            ErrorLabel {
                id: emailFieldLabel
                field: emailField
            }
            TipLabel {
                id: emailFieldTipLabel
                field: emailField
            }
            EmailField {
                id: emailField
            }
            // Password 1 field
            ErrorLabel {
                id: password1FieldLabel
                field: password1Field
            }
            TipLabel {
                id: password1FieldTipLabel
                field: password1Field
            }
            Password1Field {
                id: password1Field
                //warning: validator.name
            }
            // Password 2 field
            ErrorLabel {
                id: password2FieldLabel
                field: password2Field
            }
            TipLabel {
                id: password2FieldTipLabel
                field: password2Field
            }
            Password2Field {
                id: password2Field
                //warning: validator.name
            }

            Label {
                text: qsTr("* Пароль должен содержать символы латинского\n   алфавита в верхем и нижнем регистре, цифры\n   и как миниум один из следующих символов:\n   ! @ _ ) + ( ? $ ^ # * -")
                anchors {
                    left: password2Field.left
                    leftMargin: 5
                    top: password2Field.bottom
                    topMargin: 4
                }
                color: "#b0b0b0"
            }

            Label {
                text: qsTr("* Вводите ваши настоящие данные")
                anchors {
                    left: lastNameField.left
                    leftMargin: 5
                    top: lastNameField.bottom
                    topMargin: 4
                }
                color: "#b0b0b0"
            }

            Label {
                text: qsTr("* На него придёт письмо с кодом подтверждения")
                anchors {
                    left: emailField.left
                    leftMargin: 5
                    top: emailField.bottom
                    topMargin: 4
                }
                color: "#b0b0b0"
            }
                
            TemplateButton {
                id: registrationProcessButton
                buttonText: "Зерегистрироваться"
                enabled: !registrationBlock.isOff
                height: 45
                width: 230
                fontSize: 14
                buttonRadius: 7
                colorDefault: "#364d96"
                colorMouseOver: "#3e59b5"
                colorClicked: "#563eb5"
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 60
                    horizontalCenter: parent.horizontalCenter
                }
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 2
                    verticalOffset: 2
                    color: "#50000000"
                }
                onClicked: {
                    let fields = [
                        firstNameField, lastNameField,
                        loginField, emailField,
                        password1Field, password2Field
                    ]
                    if (!Validator.isEmpty(fields) && Validator.isAllValid(fields)) {
                        if (service.emailVerification(emailField.text, loginField.text, ))
                            registrationBlock.isOff = true
                    }
                }
            }

            TemplateButton {
                id: loginBtn1
                buttonText: "Уже зарегестрированы?"
                width: 180
                height: 30
                enabled: false
                fontSize: 11
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 20
                    left: parent.left
                    leftMargin: (parent.width - (loginBtn1.width + loginBtn2.width)) / 2
                }
            }
            TemplateButton {
                id: loginBtn2
                buttonText: "Вход"
                enabled: !registrationBlock.isOff
                width: 50
                height: 30
                fontSize: 11
                colorTextMouseOver: "#e3bf30"
                colorTextClicked: "#e37e30"
                onClicked: windowManager.openLoginWindow()
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 20
                    left: loginBtn1.right
                }
            }
        }


        Rectangle {
            id: emailValidationBlock
            color: "#85000000"
            visible: registrationBlock.isOff
            anchors {
                fill: parent
            }
            EmailCodeField {
                id: codeField
                focus: registrationBlock.isOff
                onTextEdited: {
                    codeLabel.text = codeLabel.defaultText
                    codeLabel.color = codeLabel.nonWarningColor
                    codeLabel.font.pointSize = 11
                }
            }

            Label {
                id: codeLabel
                property var field: null
                property string defaultText: qsTr("Введите код, отправленный\nна указанный вами адрес электронной почты.")
                text: defaultText
                visible: true
                font.pointSize: 11
                property color warningColor: "#d45353"
                property color nonWarningColor: "whitesmoke"
                color: nonWarningColor
                horizontalAlignment: Text.AlignHCenter
                anchors {
                    bottom: codeField.top
                    bottomMargin: 20
                    horizontalCenter: parent.horizontalCenter
                }
            }
                
            TemplateButton {
                id: acceptButton
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: codeField.bottom
                    topMargin: 25
                }
                height: codeField.height - 15
                width: codeField.width - 30
                buttonText: qsTr("Подтвердить")
                fontSize: 13
                buttonRadius: 7
                colorDefault: "#364d96"
                colorMouseOver: "#364d96"
                colorClicked: "#364d96"
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 2
                    verticalOffset: 2
                    color: "#50000000"
                }
                onClicked: {
                    if (service.codeVerification(emailField.text, codeField.text)) {
                        if (service.registration(
                            loginField.text,
                            emailField.text,
                            password1Field.text,
                            firstNameField.text,
                            lastNameField.text
                        )) {
                            registrationBlock.isOff = false
                            registrationCompleteBlock.visible = true
                        }
                    } else {
                        if (service.isError()) {
                            container.errorBarTextInfo = service.getServerMessage()
                            container.errorBarVisible = true
                            registrationBlock.isOff = false
                        } else {
                            codeLabel.text = service.getServerMessage()
                            codeLabel.color = codeLabel.warningColor
                            codeLabel.font.pointSize = 16
                            codeField.focus = true
                            codeField.text = ""
                        }
                    }
                }
            }
            TemplateButton {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: acceptButton.bottom
                    topMargin: 10
                }
                width: 100
                height: 15
                fontSize: 10
                buttonText: qsTr("Отмена")
                colorDefault: "transparent"
                colorClicked: "transparent"
                colorMouseOver: "transparent"
                colorTextMouseOver: "#9e9e9e"
                colorTextClicked: "#ffffff"
                colorTextDefault: "#707070"
                onClicked: {
                    registrationBlock.isOff = false
                }
            }
            
        }

        Rectangle {
            id: registrationCompleteBlock
            anchors.fill: parent
            color: container.color
            visible: false

            Label {
                id: registrationCompleteLabel
                text: qsTr("Регистрация прошла успешно!")
                font.pointSize: 36
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: (parent.height - openLoginButton.height - height - 40) / 2
                }
                
                color: "whitesmoke"
            }

            TemplateButton {
                id: openLoginButton
                buttonText: "Авторизоваться"
                height: 45
                width: 230
                fontSize: 14
                buttonRadius: 7
                colorDefault: "#364d96"
                colorMouseOver: "#3e59b5"
                colorClicked: "#563eb5"
                anchors {
                    top: registrationCompleteLabel.bottom
                    topMargin: 20
                    horizontalCenter: parent.horizontalCenter
                }
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 2
                    verticalOffset: 2
                    color: "#50000000"
                }
                onClicked: {
                    windowManager.openLoginWindow()
                }
            }

        }

    }
}
