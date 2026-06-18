#!/bin/bash

export PROJECT_ID=$(gcloud config get-value project)

export PROJECT_NUMBER=$(gcloud projects describe \
  $PROJECT_ID \
  --format="value(projectNumber)")

export ORG_ID=$(gcloud projects describe \
  $PROJECT_ID \
  --format="value(parent.id)")
