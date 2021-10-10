#if os(watchOS)
import ClockKit
import DatabaseClients
import SwiftUI

public final class ComplicationTimelineClient {
    private var todoClient: TodoClient

    public static let shared = ComplicationTimelineClient(todoClient: .shared)
    public static let preview = ComplicationTimelineClient(todoClient: .preview)

    private init(todoClient: TodoClient) {
        self.todoClient = todoClient
    }

    public func timeline(from family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        switch family {
        case .circularSmall:
            return circularSmallComplicationTemplate
        case .graphicBezel:
            return graphicBezelComplicationTemplate
        case .graphicCorner:
            return graphicCornerComplicationTemplate
        case .graphicCircular:
            return graphicCircularComplicationTemplate
        case .graphicRectangular:
            return graphicRectangularComplicationTemplate
        case .modularSmall:
            return modularSmallComplicationTemplate
        case .modularLarge:
            return modularLargeComplicationTemplate
        case .utilitarianSmall:
            return utiltarianSmallComplicationTemplate
        case .utilitarianLarge:
            return utiltarianLargeComplicationTemplate
        default:
            return nil
        }
    }

    private var circularSmallComplicationTemplate: CLKComplicationTemplate {
        let line1TextProvider = CLKSimpleTextProvider(text: "Tasks")
        let numberOfTasks = todoClient.numberOfRemainingTasks()
        let line2TextProvider = CLKSimpleTextProvider(text: "\(numberOfTasks.formatted())")

        return CLKComplicationTemplateCircularSmallStackText(
            line1TextProvider: line1TextProvider,
            line2TextProvider: line2TextProvider
        )
    }

    private var graphicBezelComplicationTemplate: CLKComplicationTemplate {
        let textProvider = CLKSimpleTextProvider(text: numberOfRemainingTasksString)

        let circularTemplate: CLKComplicationTemplateGraphicCircularImage = {
            let imageProvider = CLKFullColorImageProvider(
                fullColorImage: UIImage(systemName: "checkmark.circle.fill")!
            )

            return CLKComplicationTemplateGraphicCircularImage(imageProvider: imageProvider)
        }()

        return CLKComplicationTemplateGraphicBezelCircularText(
            circularTemplate: circularTemplate,
            textProvider: textProvider
        )
    }

    private var graphicCornerComplicationTemplate: CLKComplicationTemplate {
        let textProvider = CLKSimpleTextProvider(text: numberOfRemainingTasksString)

        let imageProvider = CLKFullColorImageProvider(
            fullColorImage: UIImage(systemName: "checkmark.circle.fill")!
        )

        return CLKComplicationTemplateGraphicCornerTextImage(
            textProvider: textProvider,
            imageProvider: imageProvider
        )
    }

    private var graphicCircularComplicationTemplate: CLKComplicationTemplate {
        let numberOfTasks = todoClient.numberOfRemainingTasks()

        let centerTextProvider = CLKSimpleTextProvider(text: "\(numberOfTasks.formatted())")
        centerTextProvider.tintColor = .white

        return CLKComplicationTemplateGraphicCircularStackViewText(
            content: Text("Todo"),
            textProvider: centerTextProvider
        )
    }

    private var graphicRectangularComplicationTemplate: CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicRectangularFullView(
            GraphicRectangularFullView(todoClient: todoClient)
                .environment(\.managedObjectContext, todoClient.persistence.container.viewContext)
        )
    }

    private var modularSmallComplicationTemplate: CLKComplicationTemplate {
        let line1TextProvider = CLKSimpleTextProvider(text: "Tasks")
        let numberOfTasks = todoClient.numberOfRemainingTasks()
        let line2TextProvider = CLKSimpleTextProvider(text: "\(numberOfTasks.formatted())")

        return CLKComplicationTemplateModularSmallStackText(
            line1TextProvider: line1TextProvider,
            line2TextProvider: line2TextProvider
        )
    }

    private var modularLargeComplicationTemplate: CLKComplicationTemplate {
        let headerTextProvider = CLKSimpleTextProvider(text: "Todo")
        let body1TextProvider = CLKSimpleTextProvider(text: numberOfRemainingTasksString)

        return CLKComplicationTemplateModularLargeStandardBody(
            headerTextProvider: headerTextProvider,
            body1TextProvider: body1TextProvider
        )
    }

    private var utiltarianSmallComplicationTemplate: CLKComplicationTemplate {
        let numberOfTasks = todoClient.numberOfRemainingTasks()
        let textProvider = CLKSimpleTextProvider(text: "Remaining: \(numberOfTasks.formatted())")
        return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: textProvider)
    }

    private var utiltarianLargeComplicationTemplate: CLKComplicationTemplate {

        let textProvider = CLKSimpleTextProvider(text: numberOfRemainingTasksString)
        return CLKComplicationTemplateUtilitarianSmallFlat(textProvider: textProvider)
    }

    private var numberOfRemainingTasksString: String {
        let numberOfTasks = todoClient.numberOfRemainingTasks()

        switch numberOfTasks {
        case 0:
            return "No task"
        case 1:
            return "\(numberOfTasks.formatted()) task"
        default:
            return "\(numberOfTasks.formatted()) tasks"
        }
    }
}
#endif
