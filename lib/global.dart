export 'src/exceptions/forbidden_exception.dart';
export 'src/exceptions/invalid_input_exception.dart';
export 'src/exceptions/not_found_exception.dart';
export 'src/exceptions/validation_exception.dart';

const String apiPrefix = 'api';

const String appTitle = "dartfeed";
const String feedApiVersion = "0.1";
const String feedApiName = "feed";
const String feedApiPath = "$apiPrefix/$feedApiName/$feedApiVersion/";

const int httpStatusServerNeedsSetup = 555;

const int DEFAULT_PER_PAGE = 60;
const int PAGINATED_DATA_LIMIT = 60;