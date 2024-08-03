import 'dart:async';

class DisposableWidget {

    List<StreamSubscription> _subscriptions = [];

    void cancelSubscriptions() {
        _subscriptions.forEach((subscription) {
            subscription.cancel();
        });
    }

    void addSubscription(StreamSubscription subscription) {
        _subscriptions.add(subscription);
    }

}
extension DisposableStreamSubscriton on StreamSubscription {
    void canceledBy(DisposableWidget widget) {
        widget.addSubscription(this);
    }
}