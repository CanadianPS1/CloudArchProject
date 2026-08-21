#!/bin/bash
aws lambda invoke --function-name SignUpUsers --payload fileb://events/SignUpUser.json response.json && cat response.json && \
aws lambda invoke --function-name Login --payload fileb://events/Login.json response.json && cat response.json && \
aws lambda invoke --function-name GetAllUsers --payload fileb://events/GetAllUsers.json response.json && cat response.json && \
aws lambda invoke --function-name UpdateUsers --payload fileb://events/UpdateUser.json response.json && cat response.json && \
aws lambda invoke --function-name GetAllUsers --payload fileb://events/GetAllUsers.json response.json && cat response.json && \
aws lambda invoke --function-name DeleteUsers --payload fileb://events/DeleteUser.json response.json && cat response.json && \
aws lambda invoke --function-name CreateChannel --payload fileb://events/CreateChannel.json response.json && cat response.json && \
aws lambda invoke --function-name UpdateChannelName --payload fileb://events/UpdateChannelName.json response.json && cat response.json && \
aws lambda invoke --function-name GetChannelsByUser --payload fileb://events/GetChannelsByUser.json response.json && cat response.json && \
aws lambda invoke --function-name GetAllChannels --payload fileb://events/GetAllChannels.json response.json && cat response.json && \
aws lambda invoke --function-name RemoveUserFromChannel --payload fileb://events/RemoveUserFromChannel.json response.json && cat response.json && \
aws lambda invoke --function-name AddUserToChannel --payload fileb://events/AddUserToChannel.json response.json && cat response.json && \
aws lambda invoke --function-name GetChannelById --payload fileb://events/GetChannelById.json response.json && cat response.json && \
aws lambda invoke --function-name DeleteChannel --payload fileb://events/DeleteChannel.json response.json && cat response.json