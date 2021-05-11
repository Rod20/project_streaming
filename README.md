# Flutter Video Streaming (MUX integration)

A sample Flutter project for demonstrating how to integrate video streaming service with the help of [MUX](https://mux.com).

> Article coming out soon

# Usage

If you want to try this sample app, follow the steps mentioned below (the app uses a backend API server for sending the requests to MUX):

* Clone this GitHub repository

  ```bash
  https://github.com/Rod20/project_streaming
  ```

* Create a `.env` file in the directory `flutter_stream/mux-api-server` with the following content:
  
  ```bash
  MUX_TOKEN_ID="<mux_token_id>"
  MUX_TOKEN_SECRET="<mux_token_secret>"
  ```

* Generate **MUX API Access Token** from [here](https://dashboard.mux.com/settings/access-tokens) (if you don't have a MUX account, create one by going [here](https://dashboard.mux.com/signup))

* This will generate a **Token ID** and **Token Secret**, add them to the `.env` file



* Run the API server (for testing) using the following command from the directory `flutter_stream/mux-api-server`:
  
  ```bash
  node main.js
  ```

* Get packages by running the following from the root directory:
  
  ```bash
  flutter pub get
  ```

Now, you are ready to run this app on your device, just use the this command:

```bash
cd flutter_stream
fluter run
```

# Plugins

The plugins that are used in this app are as follows:

* [dio](https://pub.dev/packages/dio) - for making HTTP POST and GET requests
* [video_player](https://pub.dev/packages/video_player) - for previewing the video to be streamed
* [intl](https://pub.dev/packages/intl) - to format `DateTime` objects

# Testing

Used the plugin [http_mock_adapter](https://pub.dev/packages/http_mock_adapter) for writing a few API mocking tests in Dart.