DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1321079701896302634/Ls-9ED65PnINeYehYfJgDf823dL3ksaAb3lUvc2lZlL7K7xl7cYKy_o856NcGcpx8f9p
# Check if .drone.env exists, then load it and pretty-print its contents
if [ -f ".drone.env" ]; then
  ENV_CONTENT=$(cat .drone.env | jq -R -s -c 'split("\n") | map(select(length > 0))')
  ENV_PRETTY=$(echo "$ENV_CONTENT" | jq -r '. | map("- " + .) | join("\\n")')
else
  ENV_PRETTY=""
fi

# Determine the color based on the build status
if [ "$DRONE_BUILD_STATUS" = "success" ]; then
  COLOR=65280 # Green
  STATUS_MESSAGE="Success ✅"
else
  COLOR=16711680 # Red
  STATUS_MESSAGE="Failure ❌"
fi

# Get the pack_hash from the environment or set a default value
PACK_HASH=${pack_hash:-"Not available"}

# Build the default description message
DESCRIPTION="<@${DRONE_COMMIT_AUTHOR}> pushed to ${DRONE_BRANCH}.\\nBuild #$DRONE_BUILD_NUMBER - Status: $STATUS_MESSAGE\\nHash: $PACK_HASH"

# Append the environment variables if they exist
if [ -n "$ENV_PRETTY" ]; then
  DESCRIPTION="${DESCRIPTION}\\n\\n**Environment Variables:**\\n$ENV_PRETTY"
fi

# Build the JSON payload (inline, single-line)
PAYLOAD="{\"username\": \"Drone\", \"avatar_url\": \"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSodFcGcfo72oDYs4w0NRBccDQ5L08m8VDnGg&s\", \"embeds\": [{\"title\": \"gamula-pack [$DRONE_BRANCH]\", \"description\": \"$DESCRIPTION\", \"color\": $COLOR}]}"

# Send the payload to Discord
echo "Payload: $PAYLOAD"
curl -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$DISCORD_WEBHOOK_URL"

