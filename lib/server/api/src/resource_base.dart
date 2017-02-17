import 'dart:async';
import 'dart:io';

import 'package:dartfeed/global.dart';
import 'package:dartfeed/tools.dart';
import 'package:dartfeed/server/server.dart';
import 'package:dartfeed/server/data/data.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rpc/rpc.dart';
import 'package:stack_trace/stack_trace.dart';

abstract class ResourceBase {
  @protected
  Logger get childLogger;

  @protected
  Future<dynamic> catchExceptionsAwait(Future toAwait()) async {
    return _catchExceptions(toAwait());
  }

//  Future checkIfSetupRequired() async {
//    if (await model.setup.isSetupRequired()) throw new SetupRequiredException();
//  }

  @protected
  @virtual
  String generateRedirect(String newId) {
    return "";
  }

  Future<dynamic> _catchExceptions(Future toAwait) async {
    RpcError output;
    dynamic exception, stackTrace;

    try {
      return await toAwait;
    } on NotAuthorizedException catch (e, st) {
      exception = e;
      stackTrace = st;
      output =
          new RpcError(HttpStatus.UNAUTHORIZED, "Not Authorized", e.message);
    } on ForbiddenException catch (e, st) {
      exception = e;
      stackTrace = st;
      output = new RpcError(HttpStatus.FORBIDDEN, "Forbidden", e.message);
    } on DataMovedException catch (e, st) {
      exception = e;
      stackTrace = st;
      String redirect = generateRedirect(e.newId);
      if (StringTools.isNullOrWhitespace(redirect))
        output = new ApplicationError(
            "Redirect information found, but could not generate new path");
      else {
        _sendRedirectHeader(redirect);
      }
    } on InvalidInputException catch (e, st) {
      exception = e;
      stackTrace = st;
      output = new BadRequestError(e.toString());
    } on DataValidationException catch (e, st) {
      exception = e;
      stackTrace = st;
      output = new BadRequestError(e.message);
      for (String field in e.fieldErrors.keys) {
        output.errors.add(new RpcErrorDetail(
            location: field,
            locationType: "field",
            message: e.fieldErrors[field]));
      }
    } on AlreadyExistsException catch (e, st) {
      exception = e;
      stackTrace = st;
      output = new RpcError(HttpStatus.CONFLICT, "Conflict", e.toString());
    } on NotFoundException catch (e, st) {
      exception = e;
      stackTrace = st;
      output = new NotFoundError(e.toString());
    } on RpcError catch (e, st) {
      childLogger.severe(e, st);
      throw e;
    } on SetupDisabledException catch (e, st) {
      exception = e;
      stackTrace = st;
      output =
          new RpcError(HttpStatus.FORBIDDEN, "Forbidden", "Setup is disabled");
    } on SetupRequiredException catch (e, st) {
      exception = e;
      stackTrace = st;
      output = new RpcError(httpStatusServerNeedsSetup, "Setup Required",
          "Setup is required");
    } catch (e, st) {
      exception = e;
      stackTrace = st;
      output = new ApplicationError(e.toString());
    }
    childLogger.severe(exception, stackTrace);
    output.errors.add(new RpcErrorDetail(
        location: Trace.format(stackTrace, terse: true),
        locationType: "stackTrace"));
    throw output;
  }

  void _sendRedirectHeader(String target) {
    context.responseStatusCode = HttpStatus.MOVED_PERMANENTLY;
    context.responseHeaders[HttpHeaders.LOCATION] = target;
    throw new RpcError(
        HttpStatus.MOVED_PERMANENTLY, " Moved Permanently", target);
  }
}
