#include "my_application.h"
#include <gst/gst.h>

int main(int argc, char** argv) {
  gst_init(&argc, &argv); 	
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
