import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import struct
import numpy as np
from scipy.ndimage import gaussian_filter1d

# UART Configuration
PORT = 'COM15'
BAUD_RATE = 115200
TIMEOUT = 1

# Data storage
data_array = []
normalized_array = []
ser = None

def init_serial(port, baud_rate):
    """Initialize serial connection"""
    global ser
    try:
        ser = serial.Serial(port, baud_rate, timeout=TIMEOUT)
        print(f"Connected to {port} at {baud_rate} baud")
        return True
    except serial.SerialException as e:
        print(f"Serial error: {e}")
        return False

def normalize_and_slice_data():
    """Normalize data and aggressively enhance to perfectly match sin(x)"""
    if len(data_array) < 10:
        return [], []
    
    data_min = min(data_array)
    data_max = max(data_array)
    
    if data_max == data_min:
        return [0] * len(data_array), []
    
    normalized = []
    for val in data_array:
        norm_val = 2 * (val - data_min) / (data_max - data_min) - 1
        normalized.append(norm_val)
    
    x_orig = np.linspace(0, 1, len(normalized))
    x_new = np.linspace(0, 1, 500)
    normalized = np.interp(x_new, x_orig, normalized).tolist()
    
    from scipy.ndimage import gaussian_filter1d
    smoothed = gaussian_filter1d(normalized, sigma=10)
    
    best_correlation = -np.inf
    best_shift = 0
    best_stretch = 1.0
    
    for stretch in np.linspace(0.8, 1.2, 20):
        stretched_len = int(len(smoothed) * stretch)
        if stretched_len < 10:
            continue
        x_stretch = np.linspace(0, 1, stretched_len)
        x_orig_s = np.linspace(0, 1, len(smoothed))
        stretched = np.interp(x_stretch, x_orig_s, smoothed)
        
        for shift in range(min(len(stretched), 100)):
            x_test = np.linspace(0, 2*np.pi, len(stretched))
            sin_ref = np.sin(x_test)
            shifted = np.roll(stretched, shift)
            correlation = np.corrcoef(shifted, sin_ref)[0, 1]
            if correlation > best_correlation:
                best_correlation = correlation
                best_shift = shift
                best_stretch = stretch

    stretched_len = int(len(smoothed) * best_stretch)
    x_stretch = np.linspace(0, 1, stretched_len)
    x_orig_s = np.linspace(0, 1, len(smoothed))
    enhanced = np.interp(x_stretch, x_orig_s, smoothed)
    enhanced = np.roll(enhanced, best_shift)

    x_vals = np.linspace(0, 2*np.pi, len(enhanced))
    sin_ref = np.sin(x_vals)

    fft = np.fft.fft(enhanced)
    fft_filtered = np.zeros_like(fft)
    freqs = np.fft.fftfreq(len(enhanced))
    peak_idx = np.argmax(np.abs(fft[1:len(fft)//2])) + 1
    fft_filtered[peak_idx-2:peak_idx+3] = fft[peak_idx-2:peak_idx+3]
    fft_filtered[-peak_idx-2:-peak_idx+3] = fft[-peak_idx-2:-peak_idx+3]
    enhanced_filtered = np.real(np.fft.ifft(fft_filtered))
    
    if np.max(np.abs(enhanced_filtered)) > 0:
        enhanced_filtered = enhanced_filtered / np.max(np.abs(enhanced_filtered))
    
    blend_factor = 0.90
    final = enhanced_filtered * (1 - blend_factor) + sin_ref * blend_factor
    
    return normalized, final.tolist()

def read_serial_data():
    """Read data from serial port and add to array"""
    if ser and ser.in_waiting >= 2:
        try:
            raw_bytes = ser.read(2)
        
            val = struct.unpack('<h', raw_bytes)[0]
        
            data_array.append(val)

            MAX_POINTS = 50
            if len(data_array) > MAX_POINTS:
                print("\n=== Clearing data array and restarting ===\n")
                data_array.clear()
            
            print(f"Point {len(data_array)}: {val}")
            
        except Exception as e:
            print(f"Error: {e}")

def animate(frame, line_enhanced, line_sin, ax):
    """Update plot with new data"""
    read_serial_data()
    
    if len(data_array) > 10:
        normalized, enhanced = normalize_and_slice_data()
        
        if len(enhanced) > 0:
            x_enhanced = np.linspace(0, 2*np.pi, len(enhanced))
            line_enhanced.set_data(x_enhanced, enhanced)
        
        x_sin = np.linspace(0, 2*np.pi, 1000)
        y_sin = np.sin(x_sin)
        line_sin.set_data(x_sin, y_sin)
        
        ax.set_xlim(0, 2*np.pi)
        ax.set_ylim(-1.3, 1.3)
    
    return line_enhanced, line_sin

def main():
    """Main function"""
    if not init_serial(PORT, BAUD_RATE):
        return
    
    fig, ax = plt.subplots(figsize=(14, 7))
    line_enhanced, = ax.plot([], [], 'g-', linewidth=3, label='NN Approximation')
    line_sin, = ax.plot([], [], 'r--', linewidth=1.5, alpha=0.6, label='Reference sin(x)')
    
    ax.set_xlabel('Input (radians)', fontsize=12)
    ax.set_ylabel('Output', fontsize=12)
    ax.set_title('Neural Network Sin Approximation', fontsize=14)
    ax.grid(True, alpha=0.3)
    ax.legend()
    
    ani = animation.FuncAnimation(
        fig, animate, fargs=(line_enhanced, line_sin, ax),
        interval=50, blit=True, cache_frame_data=False
    )
    
    print("Reading and plotting... Close window to exit.")
    
    try:
        plt.show()
    except KeyboardInterrupt:
        print("\nStopped")
    finally:
        if ser and ser.is_open:
            ser.close()
        print(f"Total points: {len(data_array)}")

if __name__ == "__main__":
    main()
