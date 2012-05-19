var models_library = models_library || {};
models_library.viscosity_turbulence = {
  "model": {
    "timestep": 0.2,
    "measurement_interval": 100,
    "viewupdate_interval": 10,
    "sun_angle": 1.5707964,
    "solar_power_density": 2000.0,
    "solar_ray_count": 24,
    "solar_ray_speed": 0.1,
    "photon_emission_interval": 20,
    "z_heat_diffusivity": 0.0,
    "background_conductivity": 0.5,
    "background_viscosity": 0.0010,
    "thermal_buoyancy": 0.0,
    "buoyancy_approximation": 1,
    "boundary": {
      "temperature_at_border": {
        "upper": 0.0,
        "lower": 0.0,
        "left": 0.0,
        "right": 0.0
      }
    },
    "structure": {
      "part": {
        "rectangle": {
          "x": 0.0,
          "y": 3.9966273,
          "width": 0.26509574,
          "height": 2.0067453
        },
        "thermal_conductivity": 0.08,
        "specific_heat": 1300.0,
        "density": 25.0,
        "transmission": 0.0,
        "reflection": 0.0,
        "absorption": 1.0,
        "emissivity": 0.0,
        "temperature": 20.0,
        "constant_temperature": true,
        "wind_speed": 0.1
      }
    }
  },
  "sensor": {
    "thermometer": [
      {
        "x": 4.0,
        "y": 5.0
      },
      {
        "x": 8.0,
        "y": 5.0
      }
    ]
  },
  "view": {
    "grid_size": 10,
    "color_palette_type": 1,
    "color_palette_x": 0.0,
    "color_palette_y": 0.0,
    "color_palette_w": 0.0,
    "color_palette_h": 0.0,
    "minimum_temperature": 0.0,
    "maximum_temperature": 40.0
  }
};