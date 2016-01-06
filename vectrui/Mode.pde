class Mode {
  int       pattern;
  int[]     numColors = new int[3];
  int[][][] thresh = new int[2][2][2];
  int[][]   args = new int[3][3];
  int[][]   timings = new int[3][6];
  int[][][] colors = new int[9][3][3];

  Mode() {
  }

  int geta(int addr) {
    if (addr == 0) {
      return pattern;
    } else if (addr < 4) {
      return numColors[addr - 1];
    } else if (addr < 12) {
      return thresh[(addr - 4) / 4][((addr - 4) % 4) / 2][(addr - 4) % 2];
    } else if (addr < 21) {
      return args[(addr - 12) / 3][(addr - 12) % 3];
    } else if (addr < 39) {
      return timings[(addr - 21) / 6][(addr - 21) % 6];
    } else if (addr < 120) {
      return colors[(addr - 39) / 9][((addr - 39) % 9) / 3][(addr - 39) % 3];
    }
    return -1;
  }

  void seta(int addr, int val) {
    if (addr == 0) {
      pattern = val;
    } else if (addr < 4) {
      numColors[addr - 1] = val;
    } else if (addr < 12) {
      thresh[(addr - 4) / 4][((addr - 4) % 4) / 2][(addr - 4) % 2] = val;
    } else if (addr < 21) {
      args[(addr - 12) / 3][(addr - 12) % 3] = val;
    } else if (addr < 39) {
      timings[(addr - 21) / 6][(addr - 21) % 6] = val;
    } else if (addr < 120) {
      colors[(addr - 39) / 9][((addr - 39) % 9) / 3][(addr - 39) % 3] = val;
    }
  }

  JSONArray j_numColors() {
    JSONArray jarr = new JSONArray();
    for (int i = 0; i < 3; i++) {
      jarr.setInt(i, numColors[i]);
    }
    return jarr;
  }

  JSONArray j_thresh() {
    JSONArray jarr = new JSONArray();
    for (int i = 0; i < 2; i++) {
      JSONArray jarr1 = new JSONArray();
      for (int j = 0; j < 2; j++) {
        JSONArray jarr2 = new JSONArray();
        for (int k = 0; k < 2; k++) {
          jarr2.setInt(k, thresh[i][j][k]);
        }
        jarr1.setJSONArray(j, jarr2);
      }
      jarr.setJSONArray(i, jarr1);
    }
    return jarr;
  }

  JSONArray j_args() {
    JSONArray jarr = new JSONArray();
    for (int i = 0; i < 3; i++) {
      JSONArray jarr1 = new JSONArray();
      for (int j = 0; j < 3; j++) {
        jarr1.setInt(j, args[i][j]);
      }
      jarr.setJSONArray(i, jarr1);
    }
    return jarr;
  }

  JSONArray j_timings() {
    JSONArray jarr = new JSONArray();
    for (int i = 0; i < 3; i++) {
      JSONArray jarr1 = new JSONArray();
      for (int j = 0; j < 6; j++) {
        jarr1.setInt(j, timings[i][j]);
      }
      jarr.setJSONArray(i, jarr1);
    }
    return jarr;
  }

  JSONArray j_colors() {
    JSONArray jarr = new JSONArray();
    for (int i = 0; i < 3; i++) {
      JSONArray jarr1 = new JSONArray();
      for (int j = 0; j < 9; j++) {
        JSONArray jarr2 = new JSONArray();
        for (int k = 0; k < 3; k++) {
          jarr2.setInt(k, colors[j][i][k]);
        }
        jarr1.setJSONArray(j, jarr2);
      }
      jarr.setJSONArray(i, jarr1);
    }
    return jarr;
  }

  JSONObject asJson() {
    JSONObject j_mode = new JSONObject();
    j_mode.setInt("pattern", pattern);
    j_mode.setJSONArray("num_colors", j_numColors());
    j_mode.setJSONArray("thresh", j_thresh());
    j_mode.setJSONArray("args", j_args());
    j_mode.setJSONArray("timings", j_timings());
    j_mode.setJSONArray("colors", j_colors());
    return j_mode;
  }

  void json_numColors(JSONArray jarr) {
    for (int i = 0; i < 3; i++) {
      numColors[i] = jarr.getInt(i);
    }
  }

  void json_thresh(JSONArray jarr) {
    for (int i = 0; i < 2; i++) {
      JSONArray jarr1 = jarr.getJSONArray(i);
      for (int j = 0; j < 2; j++) {
        JSONArray jarr2 = jarr1.getJSONArray(j);
        for (int k = 0; k < 2; k++) {
          thresh[i][j][k] = jarr2.getInt(k);
        }
      }
    }
  }

  void json_args(JSONArray jarr) {
    for (int i = 0; i < 3; i++) {
      JSONArray jarr1 = jarr.getJSONArray(i);
      for (int j = 0; j < 3; j++) {
        args[i][j] = jarr1.getInt(j);
      }
    }
  }

  void json_timings(JSONArray jarr) {
    for (int i = 0; i < 3; i++) {
      JSONArray jarr1 = jarr.getJSONArray(i);
      for (int j = 0; j < 6; j++) {
        timings[i][j] = jarr1.getInt(j);
      }
    }
  }

  void json_colors(JSONArray jarr) {
    for (int i = 0; i < 3; i++) {
      JSONArray jarr1 = jarr.getJSONArray(i);
      for (int j = 0; j < 9; j++) {
        JSONArray jarr2 = jarr1.getJSONArray(j);
        for (int k = 0; k < 3; k++) {
          colors[j][i][k] = jarr2.getInt(k);
        }
      }
    }
  }

  void fromJSON(JSONObject json) {
    pattern = json.getInt("pattern");
    json_numColors(json.getJSONArray("num_colors"));
    json_thresh(json.getJSONArray("thresh"));
    json_args(json.getJSONArray("args"));
    json_timings(json.getJSONArray("timings"));
    json_colors(json.getJSONArray("colors"));
  }
}