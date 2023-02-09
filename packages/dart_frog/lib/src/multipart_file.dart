part of '_internal.dart';

/// {@template multipart_file}
/// When in the request body be from type "multipart/form-data" and has to a file field.
/// It gets detailed information about the file.
/// {@template multipart_file}
class MultipartFile extends Equatable {
  /// {@template multipart_file}
  const MultipartFile({
    required this.fileContent,
    required this.fileName,
    this.contentType,
  });

  /// The file's content as a byte array.
  final Uint8List fileContent;

  /// The file's original name.
  final String fileName;

  /// The file's Content-Type i.e. `image/png`.
  final String? contentType;

  /// Get the file size in bytes from the [fileContent] property.
  int get fileSize => fileContent.lengthInBytes;

  @override
  List<Object?> get props => [fileContent, fileName, contentType, fileSize];
}
