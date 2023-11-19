# logthemis

## Inspiration
As avid developers, sysadmins, maintainers of multiple international open-source projects, we know how annoying it is to read large log files. Especially new developers can struggle greatly understanding errors in log files.
Finding a solution for our misery, was our calling for hackaTUM.

## What it does
It provides an intuitive and stylistic chat interface to chat with your log files. You can ask questions about the content of the files, and it will provide you with detailed insights.

## How we built it
Using generative AI and large language models, we parse the user's request, find the required lines by searching for similarity clusters, and present the summary of the content in the macOS client application.

## Challenges we ran into
Finding a NLP model that was capable of solving the task to the degree she required. This involved testing different proprietors and open source models, mostly focused on LLMs.

## Accomplishments that we're proud of
First and foremost we are proud of our amazing UI created with the one and only SwiftUI. While sadly not being a terminal we ensured that developers will feel right at home with our terminal inspired UI.
Secondly wee are also very proud of our different prompts for the GPT4-Turbo LLM, which allows the magic to happen.

## What we learned
We how to harness the power of vector databases for efficiently storing and querying large amounts of data in natural language,

## What's next for Logthemis
There are several options, to further improve Logthemis and make it production usable.
The next big milestone, would be to integrate other log types and then use it actively for the development of our projects.

