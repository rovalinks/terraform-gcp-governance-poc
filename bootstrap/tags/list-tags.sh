for KEY in $(gcloud resource-manager tags keys list \
     --parent=organizations/${ORG_ID}
    --format="value(name)"); do

  echo
  echo "===== $KEY ====="

  gcloud resource-manager tags values list \
      --parent="$KEY" \
      --format="table(shortName,name)"

done
