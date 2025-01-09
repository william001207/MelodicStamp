import SwiftUI

struct LeafletLyricsControlsView: View {
    @Binding var isTranslationVisible: Bool
    @Binding var isRomanVisible: Bool
    @Binding var typeSize: DynamicTypeSize
    
    @State private var isHovering: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            AliveButton {
                isTranslationVisible.toggle()
            } label: {
                Image(systemSymbol: .translate)
                    .foregroundStyle(
                        isTranslationVisible ? .primary
                            : isHovering ? .tertiary : .quaternary
                    )
                    .frame(height: 36)
            }

            AliveButton {
                isRomanVisible.toggle()
            } label: {
                Image(systemSymbol: .characterPhonetic)
                    .foregroundStyle(
                        isRomanVisible ? .primary
                            : isHovering ? .tertiary : .quaternary
                    )
                    .frame(height: 36)
            }

            VStack(spacing: 8) {
                let typeSizes: ClosedRange<DynamicTypeSize> = .small...(.large)

                AliveButton {
                    typeSize -~ typeSizes.lowerBound
                } label: {
                    Image(systemSymbol: .textformatSizeSmaller)
                        .foregroundStyle(isHovering && typeSize > typeSizes.lowerBound ? .primary : .quaternary)
                }

                ForEach(typeSizes, id: \.hashValue) { size in
                    let isSelected = typeSize == size
                    AliveButton {
                        typeSize = size
                    } label: {
                        Circle()
                            .frame(width: 4, height: 4)
                            .scaleEffect(isSelected ? 1.5 : 1)
                            .foregroundStyle(
                                isSelected ? .primary
                                    : isHovering ? .tertiary : .quaternary
                            )
                    }
                }

                AliveButton {
                    typeSize +~ typeSizes.upperBound
                } label: {
                    Image(systemSymbol: .textformatSizeLarger)
                        .foregroundStyle(isHovering && typeSize < typeSizes.upperBound ? .primary : .quaternary)
                }
            }
            .animation(.smooth, value: typeSize)
        }
        .font(.title2)
        .padding(.vertical, 12)
        .frame(width: 48)
        .background {
            if isHovering {
                Rectangle()
                    .foregroundStyle(.background)
                    .opacity(0.1)
            }
        }
        .clipShape(.capsule)
        .onHover { hover in
            isHovering = hover
        }
        .animation(.smooth(duration: 0.25), value: isHovering)
    }
}