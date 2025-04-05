const axios = require('axios');
const cheerio = require('cheerio');
const fs = require('fs');

const mainUrl = 'https://mifirm.net/';

// Tarayıcı benzeri headers oluştur
const headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Referer': 'https://mifirm.net/',
    'Sec-Ch-Ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
    'Sec-Ch-Ua-Mobile': '?0',
    'Sec-Ch-Ua-Platform': '"Windows"',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'same-origin',
    'Upgrade-Insecure-Requests': '1'
};

axios.get(mainUrl, { headers })
  .then(response => {
    const html = response.data;
    const $ = cheerio.load(html);

    const models = [];

    $('.newgrid').each((index, element) => {
      const modelInfo = $(element).find('h5').text().trim();
      const modelCode = $(element).find('.mini-model-code').text().trim();
      const fwTypes = [];
      const modelImage = $(element).find('img').attr('src');
      const modelPageLink = $(element).find('a').attr('href');

      $(element).find('.fw-type span.has').each((index, typeElement) => {
        const type = $(typeElement).text().trim();
        fwTypes.push(type);
      });

      models.push({
        modelInfo,
        modelCode,
        fwTypes,
        modelImage,
        modelPageLink
      });
    });

    // Modellerin her birinin sayfasını çekip içeriği çıkaralım
    const scrapeModelPages = models.map(model => {
      // Her sayfa için 1 saniye bekle
      return new Promise(resolve => setTimeout(resolve, 1000))
        .then(() => axios.get(model.modelPageLink, { headers }))
        .then(response => {
          const modelHtml = response.data;
          const model$ = cheerio.load(modelHtml);

          const innerData = [];

          model$('tbody tr').each((index, element) => {
            const miuiVersion = model$(element).find('td:nth-child(1)').text().trim();
            const androidVersion = model$(element).find('td:nth-child(2)').text().trim();
            const fileSize = model$(element).find('td:nth-child(3)').text().trim();
            const updateAt = model$(element).find('td:nth-child(4)').text().trim();
            const downloaded = model$(element).find('td:nth-child(5)').text().trim();
            const downloadLink = model$(element).find('td:nth-child(6) a').attr('href');

            const rowData = {
              miuiVersion,
              androidVersion,
              fileSize,
              updateAt,
              downloaded,
              downloadLink
            };

            innerData.push(rowData);
          });

          return {
            ...model,
            innerData
          };
        })
        .catch(error => {
          console.error(`Hata (${model.modelPageLink}):`, error.message);
          return model;
        });
    });

    Promise.all(scrapeModelPages)
      .then(updatedModels => {
        const data = {
          models: updatedModels
        };

        fs.writeFile('models.json', JSON.stringify(data, null, 2), (error) => {
          if (error) {
            console.error('Dosya yazma hatası:', error);
          } else {
            console.log('Veriler "models.json" dosyasına kaydedildi.');
          }
        });
      })
      .catch(error => {
        console.error('Hata:', error);
      });
  })
  .catch(error => {
    console.error('Ana sayfa hatası:', error.message);
    if (error.response) {
      console.error('Durum kodu:', error.response.status);
      console.error('Yanıt başlıkları:', error.response.headers);
    }
  });
