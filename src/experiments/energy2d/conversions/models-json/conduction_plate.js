var models_library = models_library || {};
models_library.conduction_plate = {
  "model": {
    "timestep": 2.0,
    "measurement_interval": 100,
    "viewupdate_interval": 10,
    "sun_angle": 1.5707964,
    "solar_power_density": 2000.0,
    "solar_ray_count": 24,
    "solar_ray_speed": 0.1,
    "photon_emission_interval": 20,
    "z_heat_diffusivity": 5.0E-4,
    "convective": false,
    "background_conductivity": 0.1,
    "background_density": 1.0,
    "background_temperature": 20.0,
    "thermal_buoyancy": 2.5E-4,
    "buoyancy_approximation": 1,
    "boundary": {
      "flux_at_border": {
        "upper": 0.0,
        "lower": 0.0,
        "left": 0.0,
        "right": 0.0
      }
    },
    "structure": {
      "part": [
        {
          "ellipse": {
            "x": 5.0,
            "y": 4.0,
            "a": 2.5,
            "b": 2.5
          },
          "thermal_conductivity": 0.01,
          "specific_heat": 1000.0,
          "density": 25.0,
          "transmission": 0.0,
          "reflection": 0.0,
          "absorption": 1.0,
          "emissivity": 0.0,
          "temperature": 80.0,
          "constant_temperature": false,
          "filled": false
        },
        {
          "rectangle": {
            "x": 0.0,
            "y": 4.0,
            "width": 10.0,
            "height": 2.0
          },
          "thermal_conductivity": 100.0,
          "specific_heat": 1000.0,
          "density": 10.0,
          "transmission": 0.0,
          "reflection": 0.0,
          "absorption": 1.0,
          "emissivity": 0.0,
          "temperature": 20.0,
          "constant_temperature": false,
          "filled": false
        }
      ]
    }
  },
  "sensor": {
    "thermometer": [
      {
        "x": 2.0,
        "y": 5.0
      },
      {
        "x": 5.0833335,
        "y": 3.4333334
      }
    ]
  },
  "view": {
    "grid": true,
    "grid_size": 10,
    "color_palette": true,
    "color_palette_type": 1,
    "color_palette_x": 0.0,
    "color_palette_y": 0.0,
    "color_palette_w": 0.0,
    "color_palette_h": 0.0,
    "minimum_temperature": 0.0,
    "maximum_temperature": 100.0
  }
};