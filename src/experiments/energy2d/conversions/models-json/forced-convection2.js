var models_library = models_library || {};
models_library.forced_convection2 = {
  "model": {
    "model_width": 0.5,
    "model_height": 0.5,
    "timestep": 0.05,
    "measurement_interval": 100,
    "viewupdate_interval": 10,
    "sun_angle": 1.5707964,
    "solar_power_density": 2000.0,
    "solar_ray_count": 24,
    "solar_ray_speed": 0.1,
    "photon_emission_interval": 20,
    "z_heat_diffusivity": 0.0,
    "background_conductivity": 1.0,
    "background_temperature": 20.0,
    "background_viscosity": 1.0,
    "thermal_buoyancy": 0.0,
    "buoyancy_approximation": 0,
    "boundary": {
      "temperature_at_border": {
        "upper": 20.0,
        "lower": 20.0,
        "left": 20.0,
        "right": 20.0
      }
    },
    "structure": {
      "part": [
        {
          "rectangle": {
            "x": 0.0,
            "y": 0.2,
            "width": 0.01,
            "height": 0.1
          },
          "thermal_conductivity": 0.08,
          "specific_heat": 1300.0,
          "density": 25.0,
          "transmission": 0.0,
          "reflection": 0.0,
          "absorption": 1.0,
          "emissivity": 0.0,
          "temperature": 50.0,
          "constant_temperature": true,
          "wind_speed": 0.1,
          "uid": "LEFT_FAN"
        },
        {
          "rectangle": {
            "x": 0.48700002,
            "y": 0.0,
            "width": 0.01,
            "height": 0.5
          },
          "thermal_conductivity": 0.08,
          "specific_heat": 1300.0,
          "density": 25.0,
          "transmission": 0.0,
          "reflection": 0.0,
          "absorption": 1.0,
          "emissivity": 0.0,
          "temperature": 0.0,
          "constant_temperature": false,
          "wind_speed": 0.05,
          "uid": "RIGHT_FAN",
          "visible": false,
          "draggable": false
        }
      ]
    }
  },
  "sensor": "\n",
  "view": {
    "grid": true,
    "grid_size": 10,
    "color_palette_type": 1,
    "color_palette_x": 0.0,
    "color_palette_y": 0.0,
    "color_palette_w": 0.0,
    "color_palette_h": 0.0,
    "minimum_temperature": 30.0,
    "maximum_temperature": 50.0,
    "graph_xlabel": "Time",
    "clock": false
  }
};