const axios = require('axios');
const cheerio = require('cheerio');
const fs = require('fs');

const mainUrl = 'https://mifirm.net/';

axios.get(mainUrl)
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
      return axios.get(model.modelPageLink)
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
          console.error('Hata:', error);
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
    console.error('Hata:', error);
  });
