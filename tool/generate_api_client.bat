pub get --packages-dir
REM pub global activate rpc
REM pause
pub run rpc:generate discovery -i lib/server/api/feed_api.dart > json/feeds.json
pause
pub global activate discoveryapis_generator
REM pause
pub global run discoveryapis_generator:generate files -i json -o lib/client/api/src