`timescale 1ns/1ps

module tb_sweep;

  parameter CNT_WIDTH   = 8;
  parameter DEAD_CYCLES = 4;

  reg clk, rst;
  reg [CNT_WIDTH-1:0] duty, period;

  wire pwm_out;
  wire hs_out, ls_out;

  pwm_gen #(.CNT_WIDTH(CNT_WIDTH)) u_pwm (
    .clk(clk), .rst(rst),
    .duty(duty), .period(period),
    .pwm_out(pwm_out)
  );

  dead_time #(.DEAD_CYCLES(DEAD_CYCLES)) u_dt (
    .clk(clk), .rst(rst),
    .pwm_in(pwm_out),
    .hs_out(hs_out),
    .ls_out(ls_out)
  );

  // Clock: 10ns = 100MHz
  initial clk = 0;
  always #5 clk = ~clk;

  // Shoot-through checker
  integer shoot_through_count;
  always @(posedge clk) begin
    if (hs_out === 1 && ls_out === 1) begin
      shoot_through_count = shoot_through_count + 1;
      $display("FAIL: Shoot-through at time %0t", $time);
    end
  end

  // Dead-time measurement using integers
  integer dead_start;
  integer dead_time_ns;
  reg measuring;

  always @(negedge hs_out) begin
    dead_start = $time;
    measuring  = 1;
  end

  always @(posedge ls_out) begin
    if (measuring) begin
      dead_time_ns = $time - dead_start;
      measuring    = 0;
    end
  end

  integer i;
  initial begin
    $dumpfile("sweep_wave.vcd");
    $dumpvars(0, tb_sweep);

    shoot_through_count = 0;
    measuring    = 0;
    dead_time_ns = 0;
    dead_start   = 0;

    rst = 1; duty = 0; period = 100;
    #20;
    rst = 0;

    $display("--------------------------------------------");
    $display("Duty Cycle Sweep - 100MHz Clock, Period=100");
    $display("--------------------------------------------");

    for (i = 0; i <= 100; i = i + 10) begin
      duty = i;
      #5000;
      $display("Duty: %0d%% | Dead-time: %0d ns | Shoot-throughs: %0d",
                i, dead_time_ns, shoot_through_count);
    end

    $display("--------------------------------------------");
    if (shoot_through_count == 0)
      $display("RESULT: ALL PASSED - Zero shoot-through detected");
    else
      $display("RESULT: FAILED - %0d shoot-throughs", shoot_through_count);
    $display("--------------------------------------------");

    $finish;
  end

endmodule
