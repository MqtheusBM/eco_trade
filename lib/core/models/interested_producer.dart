import 'package:eco_trade/core/models/user.dart'; // Precisamos disto para a classe Address

class InterestedProducer {
  final String producerId;
  final String producerName;
  final Address producerAddress;
  final double reputation;

  InterestedProducer({
    required this.producerId,
    required this.producerName,
    required this.producerAddress,
    required this.reputation,
  });

  factory InterestedProducer.fromJson(Map<String, dynamic> json) {
    return InterestedProducer(
      producerId: json['producer_id'],
      producerName: json['producer_name'],
      producerAddress: Address.fromJson(json['producer_address']),
      reputation: (json['reputation'] as num).toDouble(),
    );
  }
}
