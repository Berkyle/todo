class OrderId {
  static String getInitialId() => 'mmm'; // starting order for only-child todos

  static String getNext(String id) {
    if (id.endsWith('z')) {
      // 'mmz' -> 'mmzm'
      return id + 'm';
    } else {
      // 'mma' -> 'mmb'
      return id.substring(0, id.length - 1) + fromCharCode(orderIdRank(id[id.length - 1]) + 1);
    }
  }

  static String getPrevious(String id) {
    assert(id != 'a');

    if (id.endsWith('a')) {
      // 'mmaa' => 'mlzzm'
      var fromRight = 0;
      while (id[id.length - 1 - fromRight] == 'a' && fromRight < id.length) {
        fromRight += 1;
      }
      if (fromRight == id.length) {
        throw Exception("Failed to get previous value for id $id"); // probably like 'aaaaa' lol
      }
      final charToDecrement = id[id.length - 1 - fromRight];
      final rolledBackValue = fromCharCode(orderIdRank(charToDecrement) - 1);
      final endValue = List.filled(fromRight, 'z').join() + 'm';
      return id.substring(0, id.length - 1 - fromRight) + rolledBackValue + endValue;
    } else {
      // 'mmb' -> 'mma'
      return id.substring(0, id.length - 1) + fromCharCode(orderIdRank(id[id.length - 1]) - 1);
    }
  }

  static String getIdBetween(String smallerId, String largerId) {
    assert(smallerId.compareTo(largerId) == -1);

    if (getNext(smallerId).compareTo(largerId) == -1) {
      return getNext(smallerId);
    }
    if (smallerId.compareTo(getPrevious(largerId)) == -1) {
      return getPrevious(largerId);
    }
    return smallerId + 'm';
  }

  static int orderIdRank(String orderId) => orderId[0].codeUnits[0];

  static String fromCharCode(int charCode) => String.fromCharCode(charCode);
}
