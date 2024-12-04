# Chonnect
エンジニア専用すれ違いSNS交換アプリ

<img width="100" alt="Chonnect" src="https://github.com/user-attachments/assets/77f66312-777d-4ba6-913c-2cfa1ac3f5e8">
<br>
<img width="393" alt="Chonnect" src="https://github.com/user-attachments/assets/7469d75a-c291-4b50-9ced-79aa8fc6807b">

<br>

## 開発の経緯
ハッカソンやインターン、カンファレンスなどのエンジニアが集まる場で、様々な人と交流する機会はあるが、誰とも関わらないまま終わったり、イベントで築いた関係がその場限りで終わってしまった経験を何度かした。また、SNSを交換しようとしても自分のIDを教えたり、検索したりするのが面倒である。メンバー全員との交換となるとさらに面倒である。このアプリは、こうしたエンジニア同士の「その場限りの希薄な関係性」や「アカウント交換の煩わしさ」という問題の解決を目指している。小学生のときに夢中になった任天堂3DSのすれちがい通信からインスピレーションを受け、開発に至った。

Chonnectは、エンジニアとの「ちょっとした繋がり」を増やすために開発されたiOSアプリケーションである。

<br>

## 使用技術
* SwiftUI
* Firebase
  * Authentication
  * Cloud Firestore
  * Storage
  * App Check
  * Cloud Message
* Bluetooth(BLE)

<img src="https://github.com/user-attachments/assets/bd0c8653-cc1d-447d-8dac-c75298d0fe3d">

<br>

## こだわりポイント
### Bluetoothを用いたすれちがい通信
位置情報を利用したすれちがい通信が一般的だが、バッテリー消費量・データ通信量・プライバシー面において大きな懸念がある。本アプリでは、BLE(Bluetooth Low Energy)を用いることでこの問題を解決した。

### セキュリティの強化
本アプリはSNS的な側面を持つため、セキュリティに関しては特に慎重に考慮する必要があった。セキュリティについて次の3つの実装を行った。①プライバシーモードを設定できるようにし、プロフィールの閲覧に制限を設けた。②FirebaseのApp Checkというサービスを導入し、未承認のクライアントがバックエンドリソースにアクセスすることを防止した。これにより、アプリのバックエンドを不正使用から保護することができる。③Firebaseのセキュリティルールを適応し、データへのアクセスを制限した。
![図1](https://github.com/user-attachments/assets/1a1333bf-8a2f-4bf3-a214-918cf5063daf)

### バックグラウンドでのすれちがい
バックグラウンド状態でも通信できます。ただし、Apple側の制約の問題で一部のバックグラウンド通信はできないことが判明した。

### 洗練されたUI
チープに見えないようにUIの改善にはかなりの工数をかけた。第三者にテストをしてもらい、フィードバックをもとにした改善を何度か行った。

| スクリーンショット | 説明 |
|--------------------|------|
| <img src="https://github.com/user-attachments/assets/20e8f1d0-f4d0-45fb-80e6-4e9ad864767b" width="200"> | ログイン画面: ログイン、新規登録、パスワードリセット |
| <img src="https://github.com/user-attachments/assets/c44a117e-d5b0-4d3b-a531-9a73c4205c83" width="200"> | マイプロフィール画面(上):  |
| <img src="https://github.com/user-attachments/assets/4e523e80-cd59-40bf-902d-648c74a0d692" width="200"> | マイプロフィール画面(下): |
| <img src="https://github.com/user-attachments/assets/4df9d565-59ff-4d97-833a-0b58a49a88e1" width="200"> | プロフィール編集画面:  |
| <img src="https://github.com/user-attachments/assets/eac8684f-b1d7-4ab9-a9e7-779af78432ca" width="200"> | 技術タグ編集画面:  |
| <img src="https://github.com/user-attachments/assets/30bf858f-d152-4009-b2b9-15e0838bb640" width="200"> | 技術タグ編集画面: |
| <img src="https://github.com/user-attachments/assets/a8c64171-dec2-4e5e-86f9-4c9d5d452585" width="200"> | SNSリンク編集画面:  |
| <img src="https://github.com/user-attachments/assets/435214fc-1269-4877-8601-f707580a75e9" width="200"> | 記事編集画面: |
| <img src="https://github.com/user-attachments/assets/bf12a2f7-4318-48d0-b20e-b1d4b7ba8fc0" width="200"> | 設定画面: |


