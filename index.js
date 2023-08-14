const axios = require('axios');
const cheerio = require('cheerio'); // Cheerio kütüphanesini kullanarak HTML analizi yapacağız
const fs = require('fs');

const url = 'https://mifirm.net/model/ruby.ttt'; // Hedef URL

axios.get(url)
  .then(response => {
    const html = response.data;
    const $ = cheerio.load(html); // Sayfanın HTML yapısını analiz etmek için Cheerio kullanıyoruz

    const data = [];

    // Tablodaki her satırı dolaşarak verileri çıkarıyoruz
    $('tbody tr').each((index, element) => {
      const miuiVersion = $(element).find('td:nth-child(1)').text().trim();
      const androidVersion = $(element).find('td:nth-child(2)').text().trim();
      const fileSize = $(element).find('td:nth-child(3)').text().trim();
      const updateAt = $(element).find('td:nth-child(4)').text().trim();
      const downloaded = $(element).find('td:nth-child(5)').text().trim();
      const downloadLink = $(element).find('td:nth-child(6) a').attr('href');

      // Verileri obje olarak topluyoruz
      const rowData = {
        miuiVersion,
        androidVersion,
        fileSize,
        updateAt,
        downloaded,
        downloadLink
      };

      data.push(rowData);
    });

     // JSON formatında verileri dosyaya yazma
     fs.writeFile('veriler.json', JSON.stringify(data, null, 2), (error) => {
        if (error) {
          console.error('Dosya yazma hatası:', error);
        } else {
    // Elde edilen verileri JSON formatında yazdırıyoruz
    console.log(JSON.stringify(data, null, 2));
          console.log('Veriler "veriler.json" dosyasına kaydedildi.');
        }
      });
    })
    .catch(error => {
      console.error('Hata:', error);
    });
