#!/bin/bash

# Check if .env exists, then load it and pretty-print its contents
if [ -f ".env" ]; then
  ENV_CONTENT=$(cat .env | jq -R -s -c 'split("\n") | map(select(length > 0))')
  ENV_PRETTY=$(echo "$ENV_CONTENT" | jq -r '. | map("- " + .) | join("\\n")')
else
  ENV_PRETTY=""
fi

# Determine the color based on the pipeline status
if [ "$CI_JOB_STATUS" = "success" ]; then
  COLOR=65280 # Green
  STATUS_MESSAGE="Success ✅"
else
  COLOR=16711680 # Red
  STATUS_MESSAGE="Failure ❌"
fi

# GitLab user avatar and name
GITLAB_USER_AVATAR="https://www.gravatar.com/avatar/${CI_COMMIT_AUTHOR_EMAIL_HASH}?d=identicon"
GITLAB_USER_NAME="${GITLAB_USER_NAME:-$GITLAB_USER_EMAIL}"

# Build the default description message
DESCRIPTION="$GITLAB_USER_NAME pushed to ${CI_COMMIT_REF_NAME}.\\nPipeline #$CI_PIPELINE_IID - Status: $STATUS_MESSAGE"

# Append the environment variables if they exist
if [ -n "$ENV_PRETTY" ]; then
  DESCRIPTION="${DESCRIPTION}\\n\\n**Environment:**\\n$ENV_PRETTY"
fi

# Construct the title as a clickable link
TITLE="Pipeline #$CI_PIPELINE_IID [${CI_COMMIT_REF_NAME}]"

# Build the JSON payload with GitLab user as the embed author
PAYLOAD="{\"username\": \"GitLab\", \"avatar_url\": \"https://about.gitlab.com/images/press/logo/svg/gitlab-icon-rgb.svg\", \"embeds\": [{\"author\": {\"name\": \"$GITLAB_USER_NAME\", \"icon_url\": \"$GITLAB_USER_AVATAR\"}, \"title\": \"$TITLE\", \"url\": \"${CI_PIPELINE_URL}\", \"description\": \"$DESCRIPTION\", \"color\": $COLOR}]}"

# Debugging: Print the payload
echo "Payload: $PAYLOAD"

# Send the payload to Discord
curl -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$DISCORD_WEBHOOK_URL"

