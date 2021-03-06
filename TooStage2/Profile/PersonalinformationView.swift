//
//  PersonalinformationView.swift
//  TooStage2
//
//  Created by Yuanfan Wang on 2021/04/03.
//

import SwiftUI

struct PersonalInfomationView: View {
    
    @ObservedObject var info = CompleteInfo()
    @ObservedObject var userData = UserData.shared
    @ObservedObject var keyboard = KeyboardObserver()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var isUpdated = false
    
    init() {
        if let user = userData.data {
            info.familyName = user.familyName
            info.givenName = user.givenName
            info.sex = user.sex
            info.email = user.email
            info.date = info.birthStringToDate(user.birthDay)
            info.zipCode = String(user.postalCode)
            info.address1 = user.address1
            info.address2 = user.address2
            info.roomNumber = user.roomNumber
        }
    }
    
    func sameOrNot() -> Bool {
        if let user = userData.data {
            if info.familyName == user.familyName &&
                info.givenName == user.givenName &&
                info.sex == user.sex &&
                info.email == user.email &&
                info.date == info.birthStringToDate(user.birthDay) &&
                info.zipCode == String(user.postalCode) &&
                info.address1 == user.address1 &&
                info.address2 == user.address2 &&
                info.roomNumber == user.roomNumber {
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    func isNotAllOK() -> Bool {
        !info.isAllOK() || sameOrNot()
    }
    
    func complete() {
        // prepare birthday data
        let stringDate = info.date.dateToStringYMD()
        let arr: [String] = stringDate.components(separatedBy: "/")
        let birthDay = BirthDay(year: arr[0], month: arr[1], day: arr[2])
        let user: [String: Any] = [
            "email": info.email,
            "familyName": info.familyName,
            "givenName": info.givenName,
            "sex": info.sex,
            "postalCode": Int(info.zipCode)!,
            "address1": info.address1,
            "address2": info.address2,
            "roomNumber": info.roomNumber,
            "birthDay": [
                "year": birthDay.year,
                "month": birthDay.month ,
                "day": birthDay.day
            ]
        ]
        
        let firestoreUpdate = FirestoreUpdate(collection: "users")
        firestoreUpdate.update(document: UserStatus.shared.uid!, data: user)
        self.isUpdated = true
    }
    
    var body: some View {
        VStack {
            TitleView(present: presentationMode, title: "????????????")
            ScrollView {
                VStack {
                    
                        VStack(alignment: .leading){
                            HStack(alignment: .top) {
                                UserInfoTextFieldView(title: "???", example: "??????", userInput: $info.familyName, isOK: $info.familyNameIsOK, annotationErr: "????????????")
                                UserInfoTextFieldView(title: "???", example: "??????", userInput: $info.givenName, isOK: $info.givenNameIsOK, annotationErr: "????????????")
                                SexFieldView(title: "??????", userInput: $info.sex, isOK: $info.sexIsOK, annotationErr: "????????????????????????")
                            }
                            Text("?????????????????????????????????????????????????????????????????????????????????")
                                .font(.caption2)
                                .padding(.top, 5)
                                .foregroundColor(.gray)
                        }
                        UserInfoTextFieldView(title: "????????????", example: "too@gmail.com", userInput: $info.email, isOK: $info.emailIsOK, annotationErr: "error.....", keyboardType: .emailAddress)
                            .disabled(true)

                    
                        HStack {
                            UserInfoDateFieldView(title: "????????????", userInput: $info.date, isOK: $info.dateIsOK, showModal: $info.datePickerModal, annotationErr: "18???????????????????????????????????????")
                            
                        }
                        UserInfoTextFieldView(title: "????????????", example: "0000000", userInput: $info.zipCode, isOK: $info.zipCodeIsOK, annotationErr: "????????????????????????", keyboardType: .numberPad)
                        
                        HStack(alignment: .bottom) {
                            UserInfoTextFieldView(title: "????????????", example: "????????????", userInput: $info.address1, isOK: $info.address1IsOK, annotationErr: "????????????")
                                .disabled(true)
                        }
                        UserInfoTextFieldView(title: "????????????", example: "??????-?????????) 1231-1", userInput: $info.address2, isOK: $info.address2IsOK, annotationErr: "????????????")
                        
                        UserInfoTextFieldView(title: "????????????", example: "101", userInput: $info.roomNumber, isOK: $info.roomNumberIsOK, annotationErr: "?????????????????????????????????", keyboardType: .numberPad)

                    }
                    .padding(.horizontal)
                }
            
            FuncButtonView(text: "????????????", processing: complete, color: !isNotAllOK() ? "color1" : "color1-1")
                .disabled(isNotAllOK())
        }
        .navigationBarHidden(true)
        .background(Color("background").ignoresSafeArea())
        .animation(.easeInOut)
        .onTapGesture {
            UIApplication.shared.closeKeyboard()
        }
        .modalSheet(isPresented: $info.datePickerModal, backTapDismiss: true) {
            DatePickerModalView(date: $info.date, isOn: $info.datePickerModal)
        }
        .modalSheet(isPresented: $isUpdated) {
            MiniModalOneButtonView(
                text: "??????????????????",
                button: FuncMiniButtonView(
                    text: "?????????",
                    processing: {self.isUpdated = false}),
                isOn: $isUpdated)
        }
    }
}
