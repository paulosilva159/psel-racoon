import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkHelper {
  NetworkHelper(this.url);
  
  String url;

  Future getData() async {
    http.Response response = await http.get(url);

    if(response.statusCode == 200) {
      String data = response.body;

      return jsonDecode(data);
    } else {
     print(response.statusCode);
    }
  }
}

void bubbleSort(List list) {
  if (list == null || list.length == 0) return;

  int n = list.length;

  for (int step = 0; step < n; step++) {
    for (int i = 0; i < n - step - 1; i++) {
      if (list[i]['price_field'] > list[i + 1]['price_field']) {
        swap(list, i);
      }
    }
  }
}

void swap(List list, int i) {
  var temp = list[i];
  
  list[i] = list[i+1];
  list[i+1] = temp;
}

List checkRepeatedABC(List list) {
  List nonRepeated = List();
  nonRepeated.add(list[0]);

  int qt;

  for (int i = 0; i < list.length; i++) {
    qt = 0;
    
    for (int j = 0; j < nonRepeated.length; j++) {
      if(nonRepeated[j]['product_id'] == list[i]['product_id']) {
        qt++;
      }
    }

    if(qt == 0) {
        nonRepeated.add(list[i]);
    }
  }
  return nonRepeated;
}

List checkRepeatedD(List list) {
  List nonRepeated = List();
  nonRepeated.add(list[0]);

  int qt;

  for (int i = 0; i < list.length; i++) {
    qt = 0;

    for (int j = 0; j < nonRepeated.length; j++) {
      if(nonRepeated[j] == list[i]) {
        qt++;
      }
    }

    if(qt == 0) {
        nonRepeated.add(list[i]);
    }
  }
  return nonRepeated;
}

void main() async {
  int sumLike = 0;

  Map<String, dynamic> response = Map();

  response = {'full_name': 'Paulo Victor Vieira da Silva', 'email':'p.vieira.1559@usp.br', 'code_link':'https://github.com/paulosilva159/psel-racoon',
    'response_a': [], 'response_b': [], 'response_c': 0, 'response_d': []};

  String firstUrl = 'https://us-central1-psel-clt-ti-junho-2019.cloudfunctions.net/psel_2019_get';
  NetworkHelper firstNetworkHelper = NetworkHelper(firstUrl);
  var firstRoute = await firstNetworkHelper.getData();

  for (var details in firstRoute['posts']) {
    if(details['title'].split('_').contains('promocao')) {
      response['response_a'].add({'product_id':details['product_id'], 'price_field':details['price'].toInt()});
    }

    if(details['media'] == 'instagram_cpc' && details['likes'].toInt() > 700) {
      response['response_b'].add({'post_id':details['post_id'], 'price_field':details['price'].toInt()});
    }

    if(details['media'] == 'instagram_cpc' || details['media'] == 'facebook_cpc' || details['media'] == 'google_cpc') {
      if(int.parse(details['date'].split('/')[1]) == 5) {
        sumLike += details['likes'].toInt();
      }
    }
  }

  response['response_c'] = sumLike;

  bubbleSort(response['response_a']);
  bubbleSort(response['response_b']);

  response['response_a'] = checkRepeatedABC(response['response_a']);
  
  String secondUrl = 'https://us-central1-psel-clt-ti-junho-2019.cloudfunctions.net/psel_2019_get_error';
  NetworkHelper secondNetworkHelper = NetworkHelper(secondUrl);
  var secondRoute = await secondNetworkHelper.getData();

  for (int i = 0; i < secondRoute['posts'].length; i++) {
    for (int j = 0; j < secondRoute['posts'].length; j++) {
      if(secondRoute['posts'][i]['product_id'] == secondRoute['posts'][j]['product_id'] 
        && secondRoute['posts'][i]['price'] != secondRoute['posts'][j]['price']) {
        response['response_d'].add(secondRoute['posts'][i]['product_id']);
      }
    }
  }
  
  response['response_d'] = checkRepeatedD(response['response_d']);

  var headers = {
    'Content-Type': 'application/json',
  };

  var data = jsonEncode(response);

  var res = await http.post('https://us-central1-psel-clt-ti-junho-2019.cloudfunctions.net/psel_2019_post',
   headers: headers, body: data);
  
  if (res.statusCode != 200) throw Exception('post error: statusCode= ${res.statusCode}');
  print(res.body);
}