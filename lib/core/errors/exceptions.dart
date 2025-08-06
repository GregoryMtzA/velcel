class ServerException implements Exception{
  final message;

  ServerException({
    required this.message
  });
}

class CacheException implements Exception{

}