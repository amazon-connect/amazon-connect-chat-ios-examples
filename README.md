## Amazon Connect Chat iOS Examples

This repo contains an example on how to establish a chat iOS application using the Amazon Connect mobile SDKs. This example is not meant to be a full fledged solution, but instead demonstrates how to string together the APIs required to establish a chat.

For detailed instructions on how to build this example, follow [this blog](https://aws.amazon.com/blogs/contact-center/).

### Resources
The key resources used in this example are the following:
- [AWS Connect pod](https://cocoapods.org/pods/AWSConnect)
- [AWS Connect Participant pod](https://cocoapods.org/pods/AWSConnectParticipant)
- [AWS Core pod](https://cocoapods.org/pods/AWSCore)
- [Starscream pod](https://cocoapods.org/pods/Starscream)

### Project Structure
The key project files are under the `AmazonConnectChatiOS/AmazonConnectChatiOS/` directory:
- `AppDelegate.swift`: In charge of application set up. Here we confgure logs from AWS to be visible in the console when you run your app
- `SceneDelegate.swift`: Created by default when you create your project. It is where you can include logic on what to do when the scenes change and is where we configure the root file as ContentView
- `ContentView.swift`: Holds the business logic and how to display the buttons and the chat messages.
- `ChatWrapper.swift`: Wrapper around the calls to the Amazon Connect APIs
- `WebsocketManager.swift`: Implementation of some of the websocket functions from Starscream to control what to do when the websocket connects, there is a message, etc.
- `Message.swift`: Struct defining the message object

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

