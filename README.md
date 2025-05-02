# Sony IMX586 – V4L2 Driver for NXP i.MX8 Series (4-lane CSI2)

Linux V4L2 sub-device driver for integrating Sony IMX586 with NXP i.MX8 SoCs supporting 4-lane MIPI-CSI2 interfaces.

## Supported SoCs

| SoC           | CSI Support | Notes                            |
|---------------|-------------|----------------------------------|
| i.MX8M Plus   | 4-lane      | NXP ISP available                |
| i.MX8M Mini   | 4-lane      | No internal ISP, raw Bayer only |
| i.MX8M Nano   | 4-lane      | Low-power, raw Bayer             |
| i.MX8QM       | 8-lane (2x4)| Use 4-lane via CSI_MIPI_0       |
| i.MX8QXP      | 4-lane      | LVDS / MIPI hybrid               |

Check carrier board routing and pinmux for CSI mapping.

## Sensor Configuration

| Signal       | Description           |
|--------------|-----------------------|
| I2C Address  | 0x1a                  |
| XCLK         | 37.125 MHz            |
| RESET GPIO   | Configurable          |
| VANA         | 2.8 V analog          |
| VIF          | 1.8 V digital I/O     |
| DVDD         | 1.1 V (internal LDO)  |

## DTSI Integration

Include the appropriate `.dtsi` in your board-level device tree:

### Example for i.MX8MP

```dts
&csi1_bridge {
    status = "okay";
};

&csi1 {
    status = "okay";
    port@0 {
        imx586_ep: endpoint {
            remote-endpoint = <&imx586_out>;
            data-lanes = <1 2 3 4>;
            clock-lanes = <0>;
        };
    };
};

&i2c3 {
    imx586@1a {
        compatible = "sony,imx586";
        reg = <0x1a>;
        reset-gpios = <&gpio3 5 GPIO_ACTIVE_HIGH>;
        clocks = <&clk IMX8MP_CLK_CSI1_CORE>;
        clock-frequency = <37125000>;

        port {
            imx586_out: endpoint {
                clock-lanes = <0>;
                data-lanes = <1 2 3 4>;
                remote-endpoint = <&imx586_ep>;
            };
        };
    };
};
```

Use `imx586-imx8mp.dtsi` or `imx586-imx8qm.dtsi` as base templates.

## Installation (Out-of-tree)

```bash
sudo apt install dkms build-essential
./setup.sh
```

This builds the driver via DKMS and installs it for the active kernel.

## V4L2 Test

```bash
v4l2-ctl --list-devices
v4l2-ctl --all -d /dev/video0
```

For streaming:

```bash
gst-launch-1.0 v4l2src device=/dev/video0 ! video/x-bayer, width=4000, height=3000, framerate=30/1 ! fakesink
```

## Mode Table (Default)

| Resolution | FPS | Notes      |
|------------|-----|------------|
| 4000x3000  | 30  | QBC 12MP   |

Add more modes in `imx586_reg_tables.h` and declare them in `supported_modes[]`.

## Notes

- i.MX8M Mini/Plus use V4L2 + Media Controller pipeline
- On-chip ISP (i.MX8MP) requires additional libcamera tuning
- Use mipi_csi2 + csi + isi + v4l2 links
- CSI routing may differ per board and pinmux

## TODO

- Add 4K60 and HDR support
- Add V4L2_CID_GAIN / EXPOSURE
- Auto-focus (VCM) integration

---
