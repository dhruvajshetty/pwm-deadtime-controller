module pwm_gen #(
  parameter CNT_WIDTH = 8
)(
  input  clk,
  input  rst,
  input  [CNT_WIDTH-1:0] duty,    // 0-255, controls ON time
  input  [CNT_WIDTH-1:0] period,  // total cycle length
  output reg pwm_out
);

  reg [CNT_WIDTH-1:0] counter;

  // Counter: resets every period
  always @(posedge clk or posedge rst) begin
    if (rst)
      counter <= 0;
    else if (counter >= period - 1)
      counter <= 0;
    else
      counter <= counter + 1;
  end

  // PWM output: HIGH when counter is below duty
  always @(posedge clk)
    pwm_out <= (counter < duty);

endmodule