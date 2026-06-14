for KEY in $(gcloud resource-manager tags keys list \
    --parent=organizations/321880981428 \
    --format="value(name)"); do

  echo
  echo "===== $KEY ====="

  gcloud resource-manager tags values list \
      --parent="$KEY" \
      --format="table(shortName,name)"

done
