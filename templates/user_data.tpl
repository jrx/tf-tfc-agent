#!/bin/bash
echo "TFC_AGENT_TOKEN=${tfc_agent_token}" > /etc/tfc-agent.d/tfc-agent.conf
echo "TFC_AGENT_NAME=${tfc_agent_name}" >> /etc/tfc-agent.d/tfc-agent.conf
echo "TFC_AGENT_IMAGE=${tfc_agent_image}" >> /etc/tfc-agent.d/tfc-agent.conf