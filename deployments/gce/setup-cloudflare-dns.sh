#!/bin/bash

# Cloudflare DNS Setup Script for OpenClaw DevOps
# Sets up subdomains with flexible proxy mode

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.env"

# Check for required variables
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo -e "${RED}Error: CLOUDFLARE_API_TOKEN not set${NC}"
    echo "Please set your Cloudflare API token:"
    echo "  export CLOUDFLARE_API_TOKEN='your-api-token-here'"
    echo ""
    echo "To create an API token:"
    echo "  1. Go to https://dash.cloudflare.com/profile/api-tokens"
    echo "  2. Click 'Create Token'"
    echo "  3. Use 'Edit zone DNS' template"
    echo "  4. Select your zone (bemind.tech)"
    echo "  5. Copy the token"
    exit 1
fi

if [ -z "$CLOUDFLARE_ZONE_ID" ]; then
    echo -e "${RED}Error: CLOUDFLARE_ZONE_ID not set${NC}"
    echo "Please set your Cloudflare Zone ID:"
    echo "  export CLOUDFLARE_ZONE_ID='your-zone-id-here'"
    echo ""
    echo "To find your Zone ID:"
    echo "  1. Go to https://dash.cloudflare.com"
    echo "  2. Select your domain (bemind.tech)"
    echo "  3. Copy the Zone ID from the right sidebar"
    exit 1
fi

# Get external IP
EXTERNAL_IP=$(gcloud compute instances describe $GCP_INSTANCE \
    --zone=$GCP_ZONE \
    --project=$GCP_PROJECT \
    --format="value(networkInterfaces[0].accessConfigs[0].natIP)")

if [ -z "$EXTERNAL_IP" ]; then
    echo -e "${RED}Error: Could not get instance external IP${NC}"
    exit 1
fi

echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Cloudflare DNS Setup${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""
echo -e "Instance IP: ${GREEN}$EXTERNAL_IP${NC}"
echo -e "Zone ID: ${YELLOW}$CLOUDFLARE_ZONE_ID${NC}"
echo ""
echo "Subdomains to configure:"
echo "  - $LANDING_DOMAIN → $EXTERNAL_IP"
echo "  - $GATEWAY_DOMAIN → $EXTERNAL_IP"
echo ""

# Function to create or update DNS record
create_dns_record() {
    local subdomain=$1
    local ip=$2
    local record_name=$(echo $subdomain | sed "s/.bemind.tech//")

    echo -e "${YELLOW}Processing: $subdomain${NC}"

    # Check if record exists
    existing_record=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records?name=$subdomain&type=A" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json")

    record_id=$(echo $existing_record | jq -r '.result[0].id // empty')

    if [ -n "$record_id" ] && [ "$record_id" != "null" ]; then
        echo -e "  ↳ Record exists (ID: $record_id), updating..."

        # Update existing record
        update_result=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/$record_id" \
            -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
            -H "Content-Type: application/json" \
            --data "{
                \"type\": \"A\",
                \"name\": \"$record_name\",
                \"content\": \"$ip\",
                \"ttl\": 1,
                \"proxied\": true
            }")

        success=$(echo $update_result | jq -r '.success')

        if [ "$success" = "true" ]; then
            echo -e "  ${GREEN}✓ Updated successfully${NC}"
        else
            error_msg=$(echo $update_result | jq -r '.errors[0].message // "Unknown error"')
            echo -e "  ${RED}✗ Update failed: $error_msg${NC}"
            return 1
        fi
    else
        echo -e "  ↳ Record does not exist, creating..."

        # Create new record
        create_result=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records" \
            -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
            -H "Content-Type: application/json" \
            --data "{
                \"type\": \"A\",
                \"name\": \"$record_name\",
                \"content\": \"$ip\",
                \"ttl\": 1,
                \"proxied\": true
            }")

        success=$(echo $create_result | jq -r '.success')

        if [ "$success" = "true" ]; then
            new_record_id=$(echo $create_result | jq -r '.result.id')
            echo -e "  ${GREEN}✓ Created successfully (ID: $new_record_id)${NC}"
        else
            error_msg=$(echo $create_result | jq -r '.errors[0].message // "Unknown error"')
            echo -e "  ${RED}✗ Creation failed: $error_msg${NC}"
            return 1
        fi
    fi

    echo ""
}

# Function to set SSL mode to Flexible
set_ssl_mode() {
    echo -e "${YELLOW}Setting SSL mode to Flexible...${NC}"

    ssl_result=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/settings/ssl" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data '{"value":"flexible"}')

    success=$(echo $ssl_result | jq -r '.success')

    if [ "$success" = "true" ]; then
        echo -e "${GREEN}✓ SSL mode set to Flexible${NC}"
        echo ""
    else
        error_msg=$(echo $ssl_result | jq -r '.errors[0].message // "Unknown error"')
        echo -e "${RED}✗ SSL mode update failed: $error_msg${NC}"
        echo ""
        return 1
    fi
}

# Create DNS records
echo -e "${BLUE}Creating/Updating DNS Records...${NC}"
echo ""

create_dns_record "$LANDING_DOMAIN" "$EXTERNAL_IP"
create_dns_record "$GATEWAY_DOMAIN" "$EXTERNAL_IP"

# Set SSL mode
set_ssl_mode

# Verify DNS propagation
echo -e "${BLUE}Verifying DNS Records...${NC}"
echo ""

for domain in "$LANDING_DOMAIN" "$GATEWAY_DOMAIN"; do
    echo -e "Checking ${YELLOW}$domain${NC}..."

    dns_check=$(dig +short $domain @1.1.1.1 | head -n 1)

    if [ -n "$dns_check" ]; then
        echo -e "  ↳ Resolves to: ${GREEN}$dns_check${NC}"

        # Check if it's Cloudflare proxy
        if [[ $dns_check == 104.* ]] || [[ $dns_check == 172.* ]]; then
            echo -e "  ↳ ${GREEN}✓ Proxied through Cloudflare${NC}"
        else
            echo -e "  ↳ ${YELLOW}⚠ Direct IP (proxy may not be active yet)${NC}"
        fi
    else
        echo -e "  ↳ ${YELLOW}⚠ Not yet propagated (can take 1-5 minutes)${NC}"
    fi
    echo ""
done

echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}  DNS Setup Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo ""
echo "Your domains are now configured:"
echo "  • $LANDING_DOMAIN"
echo "  • $GATEWAY_DOMAIN"
echo ""
echo "SSL Mode: Flexible (HTTPS to Cloudflare, HTTP to origin)"
echo "Proxy Status: Enabled (orange cloud)"
echo ""
echo "Test your deployments:"
echo "  Landing:  https://$LANDING_DOMAIN"
echo "  Gateway:  https://$GATEWAY_DOMAIN"
echo ""
echo -e "${YELLOW}Note: DNS propagation can take 1-5 minutes${NC}"
