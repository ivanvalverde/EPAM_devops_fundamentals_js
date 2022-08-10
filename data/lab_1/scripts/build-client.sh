cd ../../../../shop-angular-cloudfront
npm install
ENV_CONFIGURATION="production"

if [[ -f ./dist/client-app.zip ]]
then
	rm ./dist/client-app.zip
fi

npm run build -- --configuration=${ENV_CONFIGURATION}
cd ./dist

if ! [[ -f $(which zip) ]]
then
	sudo apt-get install zip
fi

zip -r ./client-app.zip ./
