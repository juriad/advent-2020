#import <Foundation/Foundation.h>

#if DEBUG == 0
#define DebugLog(...)
#elif DEBUG == 1
#define DebugLog(...) NSLog(__VA_ARGS__)
#endif

@class State;

@interface Collector:NSObject {
    int successes;
}

@property(nonatomic, readonly) int successes;

- (void) reportSuccess;

- (BOOL) matched;

@end

@implementation Collector

@synthesize successes;

- (id) init {
    successes = 0;
    return self;
}

- (void) reportSuccess {
    successes++;
}

- (BOOL) matched {
    return successes > 0;
}

@end

@interface Rule:NSObject {
    NSString * description;
}

- (State *) enter: (State *) previous parent: (State *) parent;

@end

@interface State:NSObject {
    State * parent;
    State * previous;
    Collector * collector;
    NSString * message;
    int position;
}

- (State *) enter;
- (State *) next: (State *) previous;
- (State *) fail;

@end

@implementation Rule

- (State *) enter: (State *) previous parent: (State *) parent {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
        userInfo:nil];
}

- (NSString *)description {
   return description;
}

@end

@implementation State

- (State *) enter {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
        userInfo:nil];
}

- (State *) next: (State *) previous {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
        userInfo:nil];
}

- (State *) fail {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
        reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
        userInfo:nil];
}

@end

@class GlobalState;

@interface GlobalRule:Rule {
    Rule * rule;
}

@property(nonatomic, readonly) Rule * rule;

- (id)initWithRule:(Rule *) r;

- (GlobalState *) start:(NSString *) message collector: (Collector *) collector;

@end

@interface GlobalState:State {
    GlobalRule * rule;
}

- (id)initWithRule: (GlobalRule *) rule message: (NSString *) message collector: (Collector *) collector;

@end

@implementation GlobalRule

@synthesize rule;

- (id)initWithRule: (Rule *) r {
    description = @"Global";
    rule = r;
    return self;
}

- (State *) enter: (State *) previous parent: (State *) parent {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
            reason:[NSString stringWithFormat:@"Do not call %@ on GlobalRule", NSStringFromSelector(_cmd)]
            userInfo:nil];
}

- (GlobalState *) start:(NSString *) message collector: (Collector *) collector {
    return [[GlobalState alloc] initWithRule: self message: message collector: collector];
}

@end

@implementation GlobalState

- initWithRule: (GlobalRule *) r message: (NSString *) m collector: (Collector *) c {
    previous = NULL;
    parent = NULL;
    collector = c;
    message = m;
    position = -1;
    rule = r;
    return self;
}

- (State *) enter {
    DebugLog(@"Global %@ enter", rule);
    return [[rule rule] enter: self parent: self];
}

- (State *) next: (State *) previous {
    return NULL;
}

- (State *) fail {
    return NULL;
}

@end

@interface DelegateRule:Rule {
    Rule * rule;
}

- (id)setRule: (Rule *) rule;

@end

@implementation DelegateRule

- (id)init {
    description = @"Delegate";
    return self;
}

- (id)setRule: (Rule *) r {
    rule = r;
    return self;
}

- (State *) enter: (State *) previous parent: (State *) parent {
    return [rule enter: previous parent: parent];
}

@end

@class ConcatenationState;

@interface ConcatenationRule:Rule {
    NSMutableArray * list;
}

@property(nonatomic, readonly) NSMutableArray * list;

- (id)init: (NSString *) desc;

- (id)addRule: (Rule *) rule;

@end

@interface ConcatenationState:State {
    ConcatenationRule * rule;
    int part;
}

- (id)initWithRule: (ConcatenationRule *) r previous: (State *) p parent: (State *) q part: (int) i;

@end

@implementation ConcatenationRule

@synthesize list;

- (id)init: (NSString *) desc {
    list = [[NSMutableArray alloc]init];
    description = desc;
    return self;
}

- (id)addRule: (Rule *) rule {
    [list addObject: rule];
    return self;
}

- (State *) enter:(State *) previous parent: (State *) parent {
    return [[ConcatenationState alloc] initWithRule: self previous: previous parent: parent part: 0];
}

@end

@implementation ConcatenationState

- (id)initWithRule: (ConcatenationRule *) r previous: (State *) p parent: (State *) q part: (int) i {
    previous = p;
    parent = q;
    collector = p->collector;
    message = p->message;
    position = p->position;
    rule = r;
    part = i;
    return self;
}

- (State *) enter {
    DebugLog(@"Concat %@ enter, part %d", rule, part);
    return [[[rule list] objectAtIndex: part] enter: self parent: self];
}

- (State *) next:(State*) previous {
    DebugLog(@"Concat %@ next, part %d", rule, part);
    if (part + 1 < [[rule list] count]) {
        return [[ConcatenationState alloc] initWithRule: rule previous: previous parent: parent part: part + 1];
    }

    return [parent next: previous];
}

- (State *) fail {
    DebugLog(@"Concat %@ fail, part %d", rule, part);
    return [previous fail];
}

@end

@class DisjunctionState;

@interface DisjunctionRule:Rule {
   NSMutableArray * list;
}

@property(nonatomic, readonly) NSMutableArray * list;

- (id)init: (NSString *) desc;

- (id)addRule: (Rule *) rule;

@end

@interface DisjunctionState:State {
    DisjunctionRule * rule;
    int branch;
}

- (id)initWithRule: (DisjunctionRule *) r previous: (State *) p parent: (State *) q branch: (int) i;

@end

@implementation DisjunctionRule

@synthesize list;

- (id)init: (NSString *) desc {
    list = [[NSMutableArray alloc]init];
    description = desc;
    return self;
}

- (id)addRule: (Rule *) rule {
    [list addObject: rule];
    return self;
}

- (State *) enter:(State *) previous parent: (State *) parent {
    return [[DisjunctionState alloc] initWithRule: self previous: previous parent: parent branch: 0];
}

@end

@implementation DisjunctionState

- (id)initWithRule: (DisjunctionRule *) r previous: (State *) p parent: (State *) q branch: (int) i {
    previous = p;
    parent = q;
    collector = p->collector;
    message = p->message;
    position = p->position;
    rule = r;
    branch = i;
    return self;
}

- (State *) enter {
    DebugLog(@"Dis %@ enter, branch %d", rule, branch);
    return [[[rule list] objectAtIndex: branch] enter: self parent: self];
}

- (State *) next:(State*) previous {
    DebugLog(@"Dis %@ next, branch %d", rule, branch);
    return [parent next: previous];
}

- (State *) fail {
    DebugLog(@"Dis %@ fail, branch %d", rule, branch);
    if (branch + 1 < [[rule list] count]) {
        return [[DisjunctionState alloc] initWithRule: rule previous: self->previous parent: parent branch: branch + 1];
    }

    return [previous fail];
}

@end

@class LiteralState;

@interface LiteralRule:Rule {
    char literal;
}

@property(nonatomic, readonly) char literal;

- (id)initWithLiteral: (char) lit description: (NSString *) desc;

@end

@interface LiteralState:State {
    LiteralRule * rule;
}

- (id)initWithRule: (LiteralRule *) r previous: (State *) p parent: (State *) q;

@end

@implementation LiteralRule

@synthesize literal;

- (id)initWithLiteral: (char) lit description: (NSString *) desc {
    literal = lit;
    description = desc;
    return self;
}

- (State *) enter:(State *) previous parent: (State *) parent {
    return [[LiteralState alloc] initWithRule: self previous: previous parent: parent];
}

@end

@implementation LiteralState

- (id)initWithRule: (LiteralRule *) r previous: (State *) p parent: (State *) q {
    previous = p;
    parent = q;
    collector = p->collector;
    message = p->message;
    position = p->position + 1;
    rule = r;
    return self;
}

- (State *) enter {
    DebugLog(@"Lit %@ enter", rule);
    int len = [message length];

    if (position < len && [message characterAtIndex: position] == [rule literal]) {
        DebugLog(@"Lit %@ match", rule);
        State * next = [previous next: self];

        if (position + 1 == len) {
            if (next == NULL) {
                DebugLog(@"Lit %@ success", rule);
                [collector reportSuccess];
            }
            return [previous fail];
        } else {
            if (next == NULL) {
                DebugLog(@"Lit %@ short", rule);
                return [previous fail];
            } else {
                return next;
            }
        }
    } else {
        DebugLog(@"Lit %@ mis", rule);
        return [previous fail];
    }
}

- (State *) next:(State*) previous {
    DebugLog(@"Lit %@ next", rule);
    return [parent next: previous];
}

- (State *) fail {
    DebugLog(@"Lit %@ fail", rule);
    return [previous fail];
}

@end

typedef struct Input {
    GlobalRule * rule;
    NSArray * messages;
} Input;

ConcatenationRule * parseConcatenation(NSArray * rules, NSString * tailString) {
    NSArray * nums = [tailString componentsSeparatedByString: @" "];
    ConcatenationRule * concatRule = [[ConcatenationRule alloc] init: tailString];
    int j;
    for (j = 0; j < [nums count]; j++) {
        int r = [[nums objectAtIndex: j] intValue];
        [concatRule addRule: [rules objectAtIndex: r]];
    }
    return concatRule;
}

DisjunctionRule * parseDisjunction(NSArray * rules, NSString * tailString) {
    NSArray * parts = [tailString componentsSeparatedByString: @" | "];
    DisjunctionRule * disRule = [[DisjunctionRule alloc] init: tailString];
    int j;
    for (j = 0; j < [parts count]; j++) {
       ConcatenationRule * concatRule = parseConcatenation(rules, [parts objectAtIndex: j]);
       [disRule addRule: concatRule];
    }
    return disRule;
}

GlobalRule * loadRules(NSArray * lines, int count, BOOL override) {
    NSMutableArray * rules = [[NSMutableArray alloc] initWithCapacity:count];
    int i;
    for (i = 0; i < count * 2; i++) { // we need more rules due to gaps in demo in2
        [rules addObject: [[DelegateRule alloc] init]];
    }

    for (i = 0; i < count; i++) {
        NSString * line = [lines objectAtIndex: i];
        NSArray * headTail = [line componentsSeparatedByString: @": "];
        NSString * headString = [headTail objectAtIndex: 0];
        int head = [headString intValue];

        NSString * ruleString;
        if (override) {
            switch(head) {
                case 8:
                    ruleString = @"42 | 42 8";
                    break;
                case 11:
                    ruleString = @"42 31 | 42 11 31";
                    break;
                default:
                    ruleString = [headTail objectAtIndex: 1];
                    break;
            }
        } else {
            ruleString = [headTail objectAtIndex: 1];
        }

        Rule * rule;
        if ([ruleString containsString: @"\""]) {
            char c = [ruleString characterAtIndex: 1];
            rule = [[LiteralRule alloc] initWithLiteral: c description: ruleString];
        } else if ([ruleString containsString: @"|"]) {
            rule = parseDisjunction(rules, ruleString);
        } else {
            rule = parseConcatenation(rules, ruleString);
        }

        [[rules objectAtIndex: head] setRule: rule];
    }

    GlobalRule * global = [[GlobalRule alloc] initWithRule: [rules objectAtIndex: 0]];
    return global;
}

NSArray * loadMessages(NSArray * lines, int rulesCount) {
    NSMutableArray * messages = [[NSMutableArray alloc] init];

    int j;
    for (j = rulesCount; j < [lines count]; j++) {
        NSString * line = [lines objectAtIndex: j];
        if ([line length] > 0) {
            DebugLog(@"Line %@", line);
            [messages addObject: line];
        }
    }
    return messages;
}

Input loadData(NSString * name, BOOL override) {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath: name] != YES) {
        NSLog(@"File does not exist");
        exit(1);
    }

    NSData *data = [fileManager contentsAtPath:name];
    NSString* string = [[NSString alloc] initWithData:data encoding: NSASCIIStringEncoding];
    NSArray * lines = [string componentsSeparatedByString: @"\n"];
    DebugLog(@"Lines: %d", [lines count]);

    int rulesCount;
    for (rulesCount = 0; rulesCount < [lines count] && [[lines objectAtIndex: rulesCount] length] > 0; rulesCount++);
    DebugLog(@"Rules: %d", rulesCount);

    GlobalRule * global = loadRules(lines, rulesCount, override);

    NSArray * messages = loadMessages(lines, rulesCount);

    Input input;
    input.rule = global;
    input.messages = messages;
    return input;
}

BOOL matches(GlobalRule * global, NSString * message) {
    Collector * collector = [[Collector alloc] init];
    State * state = [global start: message collector: collector];

    while (state != NULL) {
        state = [state enter];
    }

    return [collector matched];
}

NSArray * findMatches(Input input) {
    NSMutableArray * messages = [[NSMutableArray alloc] init];

    int i;
    for (i = 0; i < [input.messages count]; i++) {
        NSString * message = [input.messages objectAtIndex: i];

        BOOL matched = matches(input.rule, message);

        if (matched) {
            DebugLog(@"Match: %@", message);
            [messages addObject: message];
        } else {
            DebugLog(@"Non-Match: %@", message);
        }
    }
    return messages;
}

void process(NSString * name, BOOL override) {
    Input input = loadData(name, override);
    NSArray * matches = findMatches(input);
    NSLog(@"Matches: %d", [matches count]);
}

int main(int argc, char *argv[]) {
    NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];

    if (argc == 0) {
        NSLog(@"Missing argument");
        exit(1);
    }

    NSString * name = [[NSString alloc] initWithCString: argv[1]];
    process(name, false);
    process(name, true);

    [myPool drain];
    return 0;
}
