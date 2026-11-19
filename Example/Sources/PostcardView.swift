import SwiftUI

struct PostcardView: View {
    let postcard: Postcard

    var body: some View {
        VStack(spacing: 10) {
            landscape
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text(postcard.title)
                .font(.system(.title3, design: .serif).weight(.semibold))
                .foregroundStyle(Color(red: 0.18, green: 0.20, blue: 0.19))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: 32)
        }
        .padding(10)
        .padding(.bottom, 6)
        .background(Color(red: 0.98, green: 0.96, blue: 0.90), in: .rect(cornerRadius: 4))
        .shadow(color: .black.opacity(0.22), radius: 8, x: 0, y: 5)
    }

    private var landscape: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            context.fill(Path(rect), with: .linearGradient(
                Gradient(colors: [postcard.sky, postcard.horizon]), startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height * 0.75)
            ))
            let diameter = size.width * 0.29
            let sun = CGRect(x: size.width * postcard.sunX - diameter / 2, y: size.height * 0.16,
                             width: diameter, height: diameter)
            context.fill(Path(ellipseIn: sun), with: .color(postcard.sun))

            context.fill(terrain(postcard.peaks, size: size), with: .color(postcard.ridge))
            context.fill(terrain([0.77, 0.62, 0.75, 0.69, 0.58], size: size), with: .color(postcard.land))
            for line in 0..<7 {
                let y = size.height * (0.76 + CGFloat(line) * 0.035)
                let x = size.width * (line.isMultiple(of: 2) ? 0.1 : 0.54)
                var path = Path()
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: x + size.width * 0.31, y: y - 3))
                context.stroke(path, with: .color(postcard.horizon.opacity(0.22)), lineWidth: 1)
            }
        }
        .clipShape(.rect(cornerRadius: 2))
    }

    private func terrain(_ points: [CGFloat], size: CGSize) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: size.height * points[0]))
            for (index, y) in points.enumerated().dropFirst() {
                path.addLine(to: CGPoint(x: size.width * CGFloat(index) / CGFloat(points.count - 1), y: size.height * y))
            }
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.closeSubpath()
        }
    }
}
