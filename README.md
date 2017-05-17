# rdss-flask-lambda-api
- Example flask AWS Lambda & API Gateway server.
- Python 3.6+

-----------------------------------------------------------

## Deployment

### Setup

Create terraform state bucket.
```
aws s3 mb --region eu-west-2 s3://<bucket_name>
```

Create `.env` file needed for deployment:
```
cp .env.example .env
```

### Zip bundle creation
This must be performed on the same arch as AWS Lambda runtime (Linux) because of the compiled binaries.
```
./bin/bundlelambda
```

### Deploy
This will run the zip bundle script and deploy using terraform.
```
./bin/deploy
```

### Manually Test Lambda API
```
http-prompt $(cd infra && terraform output api_url)
POST artists --form name=enya
GET artists
```

-----------------------------------------------------------

## Developer Setup

Create a virtualenv then install requirements:
```
make env
source env/bin/activate
make deps
```

### Local Development Server

#### 1. Create development configuration
```
cp config/development.py.sample config/development.py
export APP_CONFIG_FILE=$PWD/config/development.py
```

#### 2. Run server

##### In virtualenv

```
docker-compose run -d --service-ports db
make server-debug
```

##### In docker
```
docker-compose up
```

#### 3. Run Migrations
```
python manage.py db upgrade
```

#### 4. Manually test development server
```
http-prompt localhost:5000
POST /artists --form name=enya
GET /artists
```


-----------------------------------------------------------

## Test

1. Create testing configuration
```
cp config/testing.py.sample config/testing.py
```

2. Run tests
```
make test
```

### Lint
```
make lint
```
