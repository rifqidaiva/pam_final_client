import 'dart:async';

import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:pam_final_client/instances/client.dart';

class Server {
  static final Server _instance = Server._internal();
  final Dio _dio = Dio();

  factory Server() {
    return _instance;
  }

  Server._internal() {
    _dio.options.baseUrl = "http://localhost:8080";
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  // MARK: /ws
  /// Connect to WebSocket server
  // void ws({
  //   required Function(WebSocketChannel) onSuccess,
  //   required Function(Object) onError,
  // }) async {
  //   try {
  //     final wsUrl = Uri.parse('ws://localhost:8080/ws');
  //     final channel = WebSocketChannel.connect(wsUrl);

  //     await channel.ready;

  //     onSuccess(channel);
  //   } catch (e) {
  //     onError(e);
  //   }
  // }

  // MARK: /login
  void login({
    required String email,
    required String password,
    required Function(String) onSuccess,
    required Function(DioException) onError,
  }) async {
    try {
      var response = await _dio.post(
        "/login",
        queryParameters: {
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        onSuccess(response.data["token"]);
      } else {
        onError(DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "${response.data["message"]}",
          error: "login gagal dengan status: ${response.statusCode}",
        ));
      }
    } on DioException catch (e) {
      onError(e);
    }
  }

  // MARK: /register
  void register({
    required String email,
    required String password,
    required String name,
    required Function onSuccess,
    required Function(DioException) onError,
  }) async {
    try {
      var response = await _dio.post(
        "/register",
        queryParameters: {
          "email": email,
          "password": password,
          "name": name,
        },
      );

      if (response.statusCode == 200) {
        onSuccess();
      } else {
        onError(DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "${response.data["message"]}",
          error: "registrasi gagal dengan status: ${response.statusCode}",
        ));
      }
    } on DioException catch (e) {
      onError(e);
    }
  }

  // MARK: /user
  /// Get user data from token
  void getUserFromToken({
    required String token,
    required Function(User) onSuccess,
    required Function(DioException) onError,
  }) async {
    try {
      var response = await _dio.get(
        "/user",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        onSuccess(User.fromJson(response.data));
      } else {
        onError(DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "${response.data["message"]}",
          error:
              "gagal mendapatkan data user dengan status: ${response.statusCode}",
        ));
      }
    } on DioException catch (e) {
      onError(e);
    }
  }

  // MARK: /user?id=
  /// Get user data by id
  void getUserById({
    required int id,
    required Function(User) onSuccess,
    required Function(DioException) onError,
  }) async {
    try {
      String token = await Client().getToken();

      var response = await _dio.get(
        "/user",
        queryParameters: {
          "id": id,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        onSuccess(User.fromJson(response.data));
      } else {
        onError(DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "${response.data["message"]}",
          error:
              "gagal mendapatkan data user dengan status: ${response.statusCode}",
        ));
      }
    } on DioException catch (e) {
      onError(e);
    }
  }

  // MARK: /users
  /// Get all users except the current user
  void getUsers({
    required Function(List<User>) onSuccess,
    required Function(DioException) onError,
  }) async {
    try {
      String token = await Client().getToken();

      var response = await _dio.get(
        "/users",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        List<User> users = [];
        for (var user in response.data) {
          users.add(User.fromJson(user));
        }
        onSuccess(users);
      } else {
        onError(DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "${response.data["message"]}",
          error:
              "gagal mendapatkan data user dengan status: ${response.statusCode}",
        ));
      }
    } on DioException catch (e) {
      onError(e);
    }
  }

  // MARK: /conversation
  /// Get conversation between current user and another user
  void getConversation({
    required int otherUserId,
    required Function(List<Message>) onSuccess,
    required Function(DioException) onError,
  }) async {
    try {
      String token = await Client().getToken();

      var response = await _dio.get(
        "/conversation",
        queryParameters: {
          "other_user_id": otherUserId,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        List<Message> messages = [];
        for (var message in response.data) {
          messages.add(Message.fromJson(message));
        }
        onSuccess(messages);
      } else {
        onError(DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "${response.data["message"]}",
          error:
              "gagal mendapatkan data user dengan status: ${response.statusCode}",
        ));
      }
    } on DioException catch (e) {
      onError(e);
    }
  }

  // MARK: /allmessages
  /// Get all messages from the current user
  void getAllMessages({
    required Function(List<Message>) onSuccess,
    required Function(DioException) onError,
  }) async {
    try {
      String token = await Client().getToken();

      var response = await _dio.get(
        "/allmessages",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        List<Message> messages = [];
        for (var message in response.data) {
          messages.add(Message.fromJson(message));
        }
        onSuccess(messages);
      } else {
        onError(DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "${response.data["message"]}",
          error:
              "gagal mendapatkan data user dengan status: ${response.statusCode}",
        ));
      }
    } on DioException catch (e) {
      onError(e);
    }
  }
}

// MARK: WebSocket
/// WebSocket class to connect to the server
class WebSocket {
  static final WebSocket _instance = WebSocket._internal();
  late WebSocketChannel channel;
  StreamSubscription? _subscription;
  bool isClosed = false;

  factory WebSocket() {
    return _instance;
  }

  WebSocket._internal();

  void connect() {
    isClosed = false;
    final wsUrl = Uri.parse('ws://localhost:8080/ws');
    channel = WebSocketChannel.connect(wsUrl);
  }

  void sendMessage(String message) {
    if (!isClosed) {
      channel.sink.add(message);
    }
  }

  void listen({
    required Function(String) onMessage,
  }) async {
    var isListening = await Client().getIsListening();

    if (isClosed || isListening) return; // Mencegah double listener
    await Client().setIsListening(true);

    _subscription = channel.stream.listen(
      (message) {
        if (!isClosed) {
          onMessage(message);
        }
      },
      onDone: () async {
        await Client()
            .setIsListening(false); // Set isListening ke false jika selesai
      },
      onError: (e) async {
        await Client().setIsListening(
            false); // Set isListening ke false jika terjadi error
      },
    );
  }

  void stopListening() async {
    var isListening = await Client().getIsListening();

    if (!isListening) return;

    await Client().setIsListening(false);

    _subscription?.cancel();
    _subscription = null;
  }

  void close() {
    isClosed = true;
    stopListening();
    channel.sink.close(1000, "Normal closure");
  }
}

class User {
  int id;
  String email;
  String name;
  String? token;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      email: json["email"],
      name: json["name"],
      token: json["token"],
    );
  }
}

class Message {
  int? id;
  int senderId;
  int receiverId;
  String content;
  String? timestamp;

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["id"],
      senderId: json["sender_id"],
      receiverId: json["receiver_id"],
      content: json["content"],
      timestamp: json["timestamp"],
    );
  }

  // to json string method
  String toJson() {
    return """
    {
      "id": $id,
      "sender_id": $senderId,
      "receiver_id": $receiverId,
      "content": "$content",
      "timestamp": "$timestamp"
    }
    """;
  }
}
