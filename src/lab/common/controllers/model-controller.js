/*global define, DEVELOPMENT, d3, alert, model: true */

define(function () {

  return function ModelController(modelUrl, modelOptions, interactivesController,
                                  Model, ModelContainer, ScriptingAPI, Benchmarks) {
    var controller = {},

        // event dispatcher
        dispatch = d3.dispatch('modelLoaded');

    // ------------------------------------------------------------
    //
    // Main callback from model process
    //
    // Pass this function to be called by the model on every model step
    //
    // ------------------------------------------------------------
    function tickHandler() {
      controller.modelContainer.update();
    }

    // ------------------------------------------------------------
    //
    //   Benchmarks Setup
    //
    function setupBenchmarks() {
      controller.benchmarks = new Benchmarks(controller);
    }

    // ------------------------------------------------------------
    //
    //   Model Setup
    // ------------------------------------------------------------
    function setupModel() {
      model = new Model(modelOptions);
      model.resetTime();
      model.on('tick', tickHandler);
    }

    // ------------------------------------------------------------
    //
    // Create Model Player
    //
    // ------------------------------------------------------------
    function setupModelPlayer() {

      // ------------------------------------------------------------
      //
      // Create container view for model
      //
      // ------------------------------------------------------------
      controller.modelContainer = new ModelContainer(controller.modelUrl, model, interactivesController.getNextTabIndex);
    }

    function resetModelPlayer() {

      // ------------------------------------------------------------
      //
      // reset player and container view for model
      //
      // ------------------------------------------------------------
      controller.modelContainer.reset(controller.modelUrl, model);
    }

    /**
      Note: newModelConfig, newinteractiveViewConfig are optional. Calling this without
      arguments will simply reload the current model.
    */
    function reload(newModelUrl, newModelOptions) {
      controller.modelUrl = newModelUrl || controller.modelUrl;
      modelOptions = newModelOptions || modelOptions;
      setupModel();
      resetModelPlayer();
      dispatch.modelLoaded();
    }

    function repaint() {
      controller.modelContainer.repaint();
    }

    function resize() {
      controller.modelContainer.resize();
    }

    function state() {
      return model.serialize();
    }

    // ------------------------------------------------------------
    //
    // Public methods
    //
    // ------------------------------------------------------------

    controller.on = function(type, listener) {
      dispatch.on(type, listener);
    };

    controller.getViewContainer = function () {
      return controller.modelContainer.$el;
    };

    controller.getHeightForWidth = function (width) {
      return controller.modelContainer.getHeightForWidth(width);
    };

    controller.enableKeyboardHandlers = function () {
      return model.get("enableKeyboardHandlers");
    };

    controller.reload = reload;
    controller.repaint = repaint;
    controller.resize = resize;
    controller.state = state;
    controller.ScriptingAPI = ScriptingAPI;

    // ------------------------------------------------------------
    //
    // Public variables
    //
    // ------------------------------------------------------------
    controller.modelContainer = null;
    controller.benchmarks = null;
    controller.type = Model.type;
    controller.modelUrl = modelUrl;

    // ------------------------------------------------------------
    //
    // Initial setup of this modelController:
    //
    // ------------------------------------------------------------

    if (typeof DEVELOPMENT === 'undefined') {
      try {
        setupModel();
      } catch(e) {
        alert(e);
        throw new Error(e);
      }
    } else {
      setupModel();
    }

    setupBenchmarks();
    setupModelPlayer();

    return controller;
  };
});
