import 'package:common_bloc/common_bloc.dart';
import 'package:flusmic/flusmic.dart';
import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';
import 'models/flusmic_result.dart';

typedef BuilderFn = Widget Function(BuildContext context, FlusmicResult result);

///Controller state
class FlusmicControllerState {
  ///Last action perfomed timestamp
  final String timestamp;

  ///Main controller
  FlusmicControllerState(this.timestamp);
}

///Class for control FlusmicBuilder
class FlusmicController extends StateNotifier<FlusmicControllerState> {
  ///Constructor
  FlusmicController()
      : super(FlusmicControllerState(DateTime.now().toString()));

  ///Repeat an action
  void repeat() {
    final current = DateTime.now().toString();
    if (state.timestamp != current) state = FlusmicControllerState(current);
  }
}

///Widget for handle Flusmic requests
class FlusmicBuilder extends StatefulWidget {
  ///Widget builder
  final BuilderFn builder;

  ///Flusmic instance
  final Flusmic flusmic;

  ///Flusmic controller
  final FlusmicController controller;

  ///List of predicates to query
  final List<Predicate> predicates;

  ///Respository URL
  final String baseUrl;

  ///Language
  final String language;

  ///Main constructor
  FlusmicBuilder(
      {@required this.builder,
      @required this.predicates,
      this.baseUrl,
      this.controller,
      this.flusmic,
      this.language});

  @override
  _FlusmicBuilderState createState() => _FlusmicBuilderState();
}

class _FlusmicBuilderState extends State<FlusmicBuilder> {
  final RequestBloc _requestBloc = RequestBloc();
  RequestState _currentState = RequestState.uninitialized();
  final _flusmicController = FlusmicController();

  FlusmicController get flusmicController =>
      widget.controller ?? _flusmicController;

  @override
  void initState() {
    super.initState();
    _requestBloc.listen((state) => setState(() => _currentState = state));
    flusmicController.addListener((state) => onRepeat());
  }

  @override
  void dispose() {
    _requestBloc.close();
    super.dispose();
  }

  Future<FlusmicResponse> _perform() async => await (widget.flusmic ??
          Flusmic(
              prismicEndpoint: widget.baseUrl,
              defaultLanguage: widget.language))
      .query(widget.predicates, language: widget.language);

  void onRepeat() =>
      _requestBloc.perform(_perform, 'FlusmicRequest', withLoading: true);

  @override
  Widget build(BuildContext context) {
    return widget.builder(
        context,
        _currentState.when(
            error: (error) => FlusmicResult.error(error),
            loaded: (result, _, __) => FlusmicResult.loaded(result),
            loading: () => FlusmicResult.loading(),
            uninitialized: () => FlusmicResult.init()));
  }
}
