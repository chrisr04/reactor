/// This enum allow identify when a widget should be rebuilt by the BlocInjector.
enum BlocAspect {
  /// Prevents unnecesary rebuilts on BlocWidgets
  widget,

  /// Allows rebuilts when bloc state is changed
  contextExtension,
}
