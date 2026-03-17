# sync_app

Sync, Flutter tabanli bir duygu senkronizasyon uygulamasidir.

## Android Studio ile acma

Projeyi Android Studio'ya eklemek icin `sync_app` kok klasorunu acin.
`android` alt klasorunu tek basina acmayin.

1. Android Studio'yu acin.
2. `Open` secin.
3. `c:\Users\user\Documents\GitHub\SyncApp\sync_app` klasorunu secin.
4. Flutter ve Dart pluginleri kurulu degilse yukleyin.
5. Gradle senkronizasyonunun tamamlanmasini bekleyin.

## Mevcut yerel SDK ayari

Android proje ayari su anda [android/local.properties](android/local.properties) icinde su SDK'ya yonlendirilmis durumda:

- `sdk.dir=C:\Android`
- `flutter.sdk=C:\Users\user\flutter_sdk`

Bu makinede `C:\flutter` altindaki Flutter kurulumu Dart SDK guncelleme sirasinda kilitleniyor. Bu nedenle proje Android Studio tarafinda `C:\Users\user\flutter_sdk` ile kullanilacak sekilde ayarlandi.

## Android Studio'dan calistirma

1. Bir emulator acin veya USB debugging acik fiziksel cihaz baglayin.
2. Ust barda cihaz secimini yapin.
3. Run configuration olarak Flutter hedefini secin.
4. Gerekirse entrypoint olarak `lib/main.dart` kullanin.
5. `Run` veya `Shift+F10` ile uygulamayi baslatin.

## Terminalden calistirma

Bu makinede alternatif Flutter SDK ile calistirmak icin:

```powershell
$env:PATH = 'C:\Users\user\flutter_sdk\bin;' + $env:PATH
flutter pub get
flutter analyze
flutter run
```

## Not

Kod tarafi temiz durumda; `flutter analyze` bu proje icin hatasiz geciyor. Eger Android Studio ilk acilista cihaz gormezse Android SDK, emulator ve USB driver kurulumunu Android Studio SDK Manager uzerinden tamamlayin.
