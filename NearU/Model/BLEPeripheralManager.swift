//
//  BLEPeripheralManager.swift
//  NearU
//
//  Created by  髙橋和 on 2024/05/28.
//

import CoreBluetooth
import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import Firebase

//デバイスがペリフェラルとしてデータを提供するためのクラス
class BLEPeripheralManager: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    //サービスやキャラクタリスティックの作成を管理するインスタンス変数
    var peripheralManager: CBPeripheralManager!
    var userId: String

    let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-1234567890ab")
    let characteristicUUID = CBUUID(string: "87654321-4321-4321-4321-9876543210ba")

    init(user: User) {
        self.userId = user.id
        super.init()
        //インスタンスを作成し，デリゲードを自身に設定
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    //BLEサービスと特性を作成しアドバタイズを開始する関数
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn { //ペリフェラルのBluetoothがOnになっているか
            //CBMutableCharacteristicを使って特性を作成
            let characteristic = CBMutableCharacteristic(
                type: characteristicUUID,
                properties: [.write], //書き込み可能
                value: nil, //初期値
                permissions: [.writeable] //アクセス権，書き込み可能
            )
            //CBMutableServiceを使ってサービスを作成
            let service = CBMutableService(type: serviceUUID, primary: true)
            //サービスに作成した特性を追加
            service.characteristics = [characteristic]
            //ペリフェラルが提供するサービスとして登録
            peripheralManager.add(service)
            //startAdvertisingメソッドでBLEアドバタイズを開始
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [service.uuid]])
        }
    }
    
    //BLEペリフェラルが書き込みリクエストを受け取ったときに呼び出される関数
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests { //受け取ったリクエストを処理するfor文
            //リクエストからデータを取り出し，それをString型に変換
            if let userIdData = request.value, let receivedUserId = String(data: userIdData, encoding: .utf8) {
                print("Received userId: \(receivedUserId)")
                // 受信したユーザIDをFirestoreに保存
                Task { try await addReceivedUserIdToFirestore(receivedUserId) }
            }
            //centralmanagerに対して書き込みが成功したことを通知
            peripheralManager.respond(to: request, withResult: .success)
        }
    }

    //受信したユーザーIDをFirebase Firestoreデータベースに保存する
    func addReceivedUserIdToFirestore(_ receivedUserId: String) async throws {
        //Firestoreのドキュメントに追加
        try await Firestore.firestore().collection("users").document(userId).updateData([
            "connectList": FieldValue.arrayUnion([receivedUserId])
        ])
    }

}
