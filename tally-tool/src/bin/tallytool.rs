use eframe::{
    egui::{self, WidgetText},
    epaint::Hsva,
};

fn main() -> eframe::Result {
    tracing_subscriber::fmt::init();
    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default().with_inner_size([320.0, 240.0]),
        ..Default::default()
    };
    eframe::run_native(
        "tally-tool",
        options,
        Box::new(|cc| Ok(Box::<MyApp>::default())),
    )
}

#[derive(Default)]
enum ColorTest {
    #[default]
    Stopped,
    Started {
        color: Hsva,
        angle: u16,
        width: u8,
    },
}

#[derive(Default, PartialEq, Eq)]
enum ConnectionStatus {
    Connected,
    #[default]
    Disconnected,
}

impl Into<WidgetText> for &ConnectionStatus {
    fn into(self) -> WidgetText {
        match *self {
            ConnectionStatus::Connected => "Connected".into(),
            ConnectionStatus::Disconnected => "Disconnected".into(),
        }
    }
}

#[derive(Default)]
struct MyApp {
    ip: String,
    color_test: ColorTest,
    status: ConnectionStatus,
}

impl eframe::App for MyApp {
    fn update(&mut self, ctx: &egui::Context, frame: &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {
            ui.heading("tally-tool");
            ui.label(&self.status);
            ui.horizontal(|ui| {
                let ip = ui.label("IP: ");
                ui.add_enabled(
                    self.status == ConnectionStatus::Disconnected,
                    egui::TextEdit::singleline(&mut self.ip),
                )
                .labelled_by(ip.id);
                match self.status {
                    ConnectionStatus::Connected => {
                        if ui.button("Disconnect").clicked() {
                            self.status = ConnectionStatus::Disconnected;
                        }
                    }

                    ConnectionStatus::Disconnected => {
                        if ui.button("Connect").clicked() {
                            self.status = ConnectionStatus::Connected;
                        }
                    }
                }
            });
            match &mut self.color_test {
                ColorTest::Stopped => {
                    if ui.button("Colortest").clicked() {
                        self.color_test = ColorTest::Started {
                            color: Hsva::default(),
                            angle: 0,
                            width: 255,
                        }
                    }
                }
                ColorTest::Started {
                    color,
                    angle,
                    width,
                } => {
                    let clab = ui.label("Color: ");
                    ui.color_edit_button_hsva(color).labelled_by(clab.id);
                    ui.add(egui::Slider::new(angle, 0..=255).text("Angle"));
                    ui.add(egui::Slider::new(width, 0..=255).text("Width"));
                    if ui.button("Stop").clicked() {
                        self.color_test = ColorTest::Stopped;
                    }
                }
            }
        });
    }
}
