import 'package:flutter/material.dart';
import 'package:chip_list/chip_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xiaomi ROM Verileri',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Map<String, dynamic>> models;
  late List<Map<String, dynamic>> filteredModels = [];
  bool isLoading = true; // Durumu yükleme olarak başlat

  @override
  void initState() {
    super.initState();
    fetchModels();
  }

  Future<void> fetchModels() async {
    final response = await http.get(
      Uri.parse(
        'https://raw.githubusercontent.com/codermert/XiaomiROMTWRPFiles__Scrape/main/models.json',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        models = List<Map<String, dynamic>>.from(jsonData['models']);
        filteredModels = models;
        isLoading = false; // Yükleme tamamlandı
      });
    } else {
      throw Exception('Failed to load models');
    }
  }

  void filterModels(String keyword) {
    setState(() {
      filteredModels = models
          .where((model) =>
      model['modelInfo']
          .toLowerCase()
          .contains(keyword.toLowerCase()) ||
          model['fwTypes']
              .toString()
              .toLowerCase()
              .contains(keyword.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xiaomi ROM Modelleri'),
        elevation: 0, // Remove the shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: [Colors.yellow[700]!, Colors.redAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Yazılım Geliştirici',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Coder Mert',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) => filterModels(value),
              decoration: InputDecoration(
                labelText: 'Ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Text(
            'Toplam Model Sayısı: ${filteredModels.length}',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: isLoading // isLoading durumunu kontrol et
                ? Center(
              child: CircularProgressIndicator(), // Yüklenirken dönme animasyonu göster
            )
                : ListView.builder(
              itemCount: filteredModels.length,
              itemBuilder: (context, index) {
                final modelInfo = filteredModels[index]['modelInfo'];
                final modelTitle = modelInfo.split('\n')[0];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ModelDetailPage(model: filteredModels[index]),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      gradient: LinearGradient(
                        colors: [Colors.yellow[700]!, Colors.redAccent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        tileMode: TileMode.clamp,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.network(
                          filteredModels[index]['modelImage'],
                          width: 50.0,
                          height: 50.0,
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                modelTitle,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.0),
                              Wrap(
                                spacing: 4.0,
                                runSpacing: 4.0,
                                children: filteredModels[index]['fwTypes']
                                    .map<Widget>((fwType) {
                                  return Chip(
                                    label: Text(fwType),
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.0,
                                    ),
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.bolt,
                          color: Colors.white70,
                          size: 30.0,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ModelDetailPage extends StatelessWidget {
  final Map<String, dynamic> model;

  ModelDetailPage({required this.model});

  @override
  Widget build(BuildContext context) {
    final innerDataList = List<Map<String, dynamic>>.from(model['innerData']);

    return Scaffold(
      appBar: AppBar(
        title: Text(model['modelInfo']),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: [Colors.yellow[700]!, Colors.redAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.adb),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return       Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      gradient: LinearGradient(
                        colors: [Colors.yellow[700]!, Colors.redAccent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        tileMode: TileMode.clamp,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Flaşlama Talimatları (#codermert)',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          '1. Firmware hızlı önyükleme yazılımı ise, .tgz formatında olmalıdır. Değilse, .gz uzantısını .tgz olarak yeniden adlandırın ve WinRAR kullanarak açın.',
                        ),
                        Text(
                          '2. Hızlı önyükleme yazılımı için, en son XiaomiFlash\'ı indirin. İndirildikten sonra aracı ayıklayın.',
                        ),
                        Text(
                          '3. XiaoMiFlash.exe\'yi açın. Gerekirse sürücüyü yükleyin. Seç\'e tıklayın ve flash_all.bat içeren firmware/ROM klasörünü seçin.',
                        ),
                        Text(
                          '4. Cihazınızın önyükleme kilidi açık olduğundan emin olun veya telefonunuzu EDL moduna (9008) almak için yanıp sönmesini sağlayın.',
                        ),
                        Text(
                          '5. Telefonu Hızlı önyükleme moduna almak için Güç ve Ses düğmelerini 5-10 saniye basılı tutun. Hızlı önyükleme görüntülendiğinde düğmeleri bırakın.',
                        ),
                        Text(
                          '6. Telefonunuzu bilgisayara bağlayın. Cihazı taramak için Yenile\'ye tıklayın. Bir cihaz OK olarak görünüyorsa, devam edin.',
                        ),
                        Text(
                          '7. Tümünü temizle seçeneğini işaretleyin (çok önemli). İşaretlenmezse, flaşlama işlemi tamamlandıktan sonra cihazınız KİLİTLİ ÖNYÜKLEYİCİ durumunda kalacaktır.',
                        ),
                        Text(
                          '8. Flaş\'a tıklayın ve başarılı veya herhangi bir hata görülene kadar bekleyin.',
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20.0),
          Image.network(model['modelImage']),
          SizedBox(height: 20.0),
          Wrap(
            spacing: 8.0,
            children: model['fwTypes'].map<Widget>((fwType) {
              return Chip(
                label: Text(fwType),
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 12.0,
                ),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: innerDataList.length,
              itemBuilder: (context, index) {
                final innerData = innerDataList[index];

                // Format date using intl package

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: LinearGradient(
                      colors: [Colors.yellow[700]!, Colors.redAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      tileMode: TileMode.clamp,
                    ),
                  ),
                  child: ListTile(
                    title: Text('MIUI Version: ${innerData['miuiVersion']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Android Version: ${innerData['androidVersion']}'),
                        Padding(
                          padding: EdgeInsets.only(top: 24.0, bottom: 10.0),
                          child: Row(
                            children: [
                              Icon(Icons.download, size: 20.0, color: Colors.white),
                              SizedBox(width: 4.0),
                              Text('Toplam indirme: ${innerData['downloaded']}'),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.update, size: 20.0, color: Colors.white),
                            SizedBox(width: 4.0),
                            Text('Son Güncelleme: ${innerData['updateAt']}'),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward, color: Colors.white70, size: 30.0),
                    onTap: () {
                      // Handle inner data item tap if needed
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
