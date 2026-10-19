import 'dart:async';

abstract class AppEvent {
  const AppEvent();
}

class FirmBlockedEvent extends AppEvent {
  final String message;
  final String? requestId;

  const FirmBlockedEvent(this.message, {this.requestId});
}

class SubscriptionExpiredEvent extends AppEvent {
  final String message;
  final String? requestId;

  const SubscriptionExpiredEvent(this.message, {this.requestId});
}

class UnauthorizedEvent extends AppEvent {
  const UnauthorizedEvent();
}

class AppEventBus {
  AppEventBus._();
  static final AppEventBus instance = AppEventBus._();

  final _controller = StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get stream => _controller.stream;

  Stream<T> on<T extends AppEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  void emit(AppEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void dispose() {
    _controller.close();
  }
}
