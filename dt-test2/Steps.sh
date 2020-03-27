cd dt-test2
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

gcloud config set project gcs-tut

gcloud components update 

gcloud config set run/region us-central1

gsutil mb gs://my1testbucket

gsutil mb gs://my2blurredbuucket

gsutil notification create -t myRunTopic -f json gs://my1testbucket

gcloud builds submit --tag gcr.io/gcs-tut/pubsub

gcloud run deploy pubsub-tutorial --image gcr.io/gcs-tut/pubsub --set-env-vars=BLURRED_BUCKET_NAME=my2blurredbuucket

gcloud projects add-iam-policy-binding gcs-tut \
     --member=serviceAccount:service-240242700500@gcp-sa-pubsub.iam.gserviceaccount.com \
     --role=roles/iam.serviceAccountTokenCreator
     
gcloud iam service-accounts create cloud-run-pubsub-invoker \
     --display-name "Cloud Run Pub/Sub Invoker"
     
gcloud run services add-iam-policy-binding pubsub-tutorial \
   --member=serviceAccount:cloud-run-pubsub-invoker@gcs-tut.iam.gserviceaccount.com \
   --role=roles/run.invoker
   
gcloud pubsub subscriptions create myRunSubscription --topic myRunTopic \
   --push-endpoint=https://pubsub-tutorial-ogr4gw2kka-uc.a.run.app/ \
   --push-auth-service-account=cloud-run-pubsub-invoker@gcs-tut.iam.gserviceaccount.com
   
#gcloud pubsub topics publish myRunTopic --message "Runner"
#
#gcloud pubsub topics create myRunTopic


gsutil cp lake.jpg gs://my1testbucket

gsutil ls -a gs://my2blurredbuucket


















# cleaning %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gcloud run services delete pubsub-tutorial

gcloud pubsub topics delete myRunTopic

gcloud pubsub subscriptions delete myRunSubscription

gcloud container images delete gcr.io/gcs-tut/pubsub:latest

gcloud iam service-accounts delete cloud-run-pubsub-invoker@gcs-tut.iam.gserviceaccount.com

gcloud config unset run/region

gcloud config unset project

gsutil rm -r gs://my1testbucket

gsutil rm -r gs://my2blurredbuucket